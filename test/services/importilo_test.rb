require 'helpers/vcr_helper'
require 'importilo'

class EventTest < ActiveSupport::TestCase

  test 'sukcesa Meetup eventa datumo' do

    horzono = "Canada/Eastern"

    VCR.use_cassette "meetup_success" do
      expected = {
        "titolo" => "Esperanto-Toronto: Socia kunveno",
        "urbo" => "Toronto",
        "ligilo" => "https://www.meetup.com/Esperanto-Toronto/events/nbplfqyzmbfb/",
        "reta" => false,
        "landa_id"=>"ca",
        "latitudo"=>43.66590881347656,
        "longitudo"=>-79.38521575927734,
        "adreso" => "Aroma Espresso Bar,  618 Yonge Street",
        "horzono"=>horzono,
        "komenco"=>Time.find_zone("UTC").parse("2019-09-03 22:00:00").in_time_zone(horzono).strftime("%Y-%m-%d %H:%M"),
        "fino"=>Time.find_zone("UTC").parse("2019-09-03 23:30:00").in_time_zone(horzono).strftime("%Y-%m-%d %H:%M:%S"),
        "enhavo" => "English below Ni kunvenas unufoje monate por trinki kafon kaj ĝui konversacion en Esperanto pri io ajn. Je 19:30 kelkaj el ni iras al unu el la apudaj restoracioj por manĝi kaj daŭrigi la konversaciojn. Se vi vizitos nin el eksterurbe kaj vi ne povas trafi unu el ĉi tiuj kunvenoj, bonvolu sendi retmesaĝon al esperanto.toronto(ĉe)gmail.com, por ke ni eventuale povu ŝanĝi la daton de unu kunveno, aŭ aldoni kroman. We meet once a month to drink coffee and enjoy conversation in Esperanto about anything. At 7:30 some of us go to one of the nearby reastaurants to eat and continue the conversations. If you are visiting us from out of town and can’t make one of these meetings, please send an email to esperanto.toronto(at)gmail.com so that we can change the date of one meeting or add another one in order to accommodate you. Ĉe la okcidenta flanko de Yonge Street, unu strato norde de Wellesley Street (metroo Wellesley) / On the west side of Yonge Street, one block north of Wellesley Street (Wellesley subway)",
        "priskribo" => "Socia kunveno"
      }

      datumo = Importilo.new('https://www.meetup.com/Esperanto-Toronto/events/nbplfqyzmbfb/').datumo.to_h

      assert_not_nil datumo

      assert_equal expected, datumo
    end
  end

  test 'sukcesa Meetup evento' do
    lando = create(:lando, :kanado)
    horzono = "Canada/Eastern"

    VCR.use_cassette "meetup_success" do
      evento = Importilo.new('https://www.meetup.com/Esperanto-Toronto/events/nbplfqyzmbfb/').al_evento

      assert_equal evento.country, lando
      assert_equal evento.date_start, Time.find_zone("UTC").parse("2019-09-03 22:00:00").in_time_zone(horzono)
      assert_equal evento.date_end, Time.find_zone("UTC").parse("2019-09-03 23:30:00").in_time_zone(horzono)
    end
  end

  test 'malsukcesa Meetup' do
    VCR.use_cassette "meetup_failure" do
      datumo = Importilo.new('https://www.meetup.com/Espera').datumo

      assert_not datumo.success?
    end
  end

end
