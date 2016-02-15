require 'test_helper'

class SiteTest < ActiveSupport::TestCase

  setup do
    @site = sites(:one)
  end

  test "invalid without a name" do
    @site.name = nil
    assert @site.invalid?
  end

  test "creates a new meter on it's creation" do
    site = Site.new({name: "Site", latitude: 20.12345, longitude: -20.12345})
    site.save

    assert_equal site.meters.count, 1
    assert_equal site.active_meter.installation_date, site.created_at.to_date
  end

  test "changes the meter" do
    old_meter =  @site.active_meter

    @site.update_meter({installation_date: Date.today})
    #C'est necessaire relire le site du donées de base
    #'Fixture' va mantenir l'association antérieur
    @site.reload

    assert_not old_meter.active
    refute_nil @site.active_meter
    assert_equal @site.active_meter.installation_date, Date.today
  end

  test ".creates_new_meter" do
    site = Site.create({name: "New Site"})
    #Avec send, on peut executer les méthodes privées
    site.send(:create_new_meter)

    assert_equal site.meters.count, 1
    assert site.active_meter #il y a un compteur actif
  end

  test ".meter_at" do
    site = sites(:populated_site)
    meter = site.send(:meter_at, Date.new(2016,01,20))
    assert_equal meters(:second_meter), meter
  end

  # Test de la méthode que cherche un index à un jour specifique
  # Les information de la base des données ce sont:
  # On n'a vas pas populer la base de donnés avec le calcul, alors
  # tous les 'entre-jours' n'ont pas un index.

  #Date	        01/01/16    04/01/16    10/01/16    12/01/16     18/01/16   25/01/16   30/01/16     05/02/16
  #What?	      Inst. Site	Data Entry  Data Entry  Chang. Meter Data Entry Data Entry Chang. Meter Data Entry
  #Meter:index  C1: 0       C1:40       C1:70       C1:70        C2:180     C2:250     C2:250       C3:40
  #Meter:index  -	          -           -           C2:150       -          -          C3:0         -
  #Prod. Cum    0		        40          70          70           100        170        170          210

  # Trouver un index du site à une date qui on peut trouver sur la
  # base de donées
  test "finds acumulated production for a given day" do
    site = sites(:populated_site)

    acumulated_production = site.acumulated_production_at(Date.new(2016,01,25))
    assert_equal 170, acumulated_production
  end

  # Trouver un index du site à une date qui one ne peut pas trouver sur
  # la base de donés. On espére que la méthode peut trouver le valeur plus
  # nouveu avant la date specifiée
  test "finds acumulated production if theres no reading to the given day" do
    site = sites(:populated_site)

    acumulated_production = site.acumulated_production_at(Date.new(2016,01,20))

    assert_equal 100, acumulated_production
  end

  #### Test du calcul à partir des production journalières ####

  # On utilisant du site 'populated', on va créer 2 enregistrement d'index
  # en deux compteurs différents
  test "crée des index à partir des production journalières" do
    site = sites(:populated_site)

    site.create_missing_readings_from_daily_productions
    #Dia 08/01 espera-se ter uma leitura de 45
    #Dia 02/02 espera-se ter uma eitura de 5

    first_meter_reading_created = MeterReading.find_by_date(Date.new(2016, 1, 8))
    assert_not_nil first_meter_reading_created
    assert_equal 45, first_meter_reading_created.value

    second_meter_reading_created = MeterReading.find_by_date(Date.new(2016, 2, 2))
    assert_not_nil second_meter_reading_created
    assert_equal 5, second_meter_reading_created.value
  end

end
