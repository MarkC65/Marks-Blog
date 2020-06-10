module ApplicationHelper

  require 'net/http'

  def gravatar?(gravatar_url)
      uri = URI.parse(gravatar_url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
  end

  def avatar_for (user)
    avatar_hash = Digest::MD5.hexdigest(user.email)
    gravatar_url = "http://www.gravatar.com/avatar/#{avatar_hash}.png?r=g&d=404"
    resp = gravatar?(gravatar_url)
    if resp.code.to_i != 404 # from d=404 parameter
      image_tag(gravatar_url, alt: user.display_name, class: "rounded mx-auto d-block")
    else
      gravatar_url = "http://d1kwem27qp6c37.cloudfront.net/#{avatar_hash}"
      resp = gravatar?(gravatar_url)
      if resp.code.to_i == 200
        image_tag(gravatar_url, alt: user.display_name, class: "rounded mx-auto d-block")
      else
        image_tag("http://d1kwem27qp6c37.cloudfront.net/default", alt: user.display_name, class: "rounded mx-auto d-block")
      end
    end
  end

end
