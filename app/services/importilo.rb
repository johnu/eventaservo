# frozen_string_literal: true

class Importilo
  include HTTParty
  base_uri "https://eventa-servo-importilo.herokuapp.com/"
  headers "Content-Type" => "application/json", "Accept" => "application/json"

  attr_reader :url

  def initialize(url)
    @url = url
  end

  def datumo
    self.class.post(retejaAdreso, body: {"URL": url}.to_json).tap do |datumo|
      if datumo.success?
        datumo["latitudo"] = datumo["latitudo"].to_f
        datumo["longitudo"] = datumo["longitudo"].to_f
      end
    end
  end

  def al_evento(evento = Event.new)
    datumo = self.datumo

    if datumo.success?
      evento.title = datumo["titolo"]
      evento.description = datumo["priskribo"]&.first(400)
      evento.content = datumo["enhavo"]
      evento.online = datumo["reta"]

      unless evento["reta"]
        evento.address = datumo["adreso"]
        evento.latitude = datumo["latitudo"]
        evento.longitude = datumo["longitudo"]
      end

      evento.country = Country.find_by_code(datumo["landa_id"])
      evento.city = datumo["urbo"]

      horzono = datumo["horzono"]

      evento.time_zone = horzono
      evento.date_start = Time.find_zone(horzono).parse(datumo["komenco"])
      evento.date_end = Time.find_zone(horzono).parse(datumo["fino"])

      evento.import_url = url
      evento.site = datumo["ligilo"]
    else
      evento.errors.add(:base, "Ni ne sukcesis importi tiun eventon.")
    end

    evento
  end

  private

  def retejaAdreso
    case URI(@url).host
    when /.*meetup.*/
      "/meetup"
    end
  end

end
