module Jobs
  class Mailer
    @queue = :high

    def self.perform(args)
      require "cgi"
      require "mail"

      mail = Mail.new do
        from CONFIG[:noreply]
        reply_to args["from"]
        to args["to"]
        subject "Potential client has messaged you"
      end

      # Generate the text body
      content = "From: #{args["from"]}\n"
      args["fields"].each do |name, value|
        content << "#{name}: #{value == "" ? "[Empty]" : CGI::escapeHTML(value)}\n"
        content << "\n" if value.length >= 150
      end

      content << "\n-------------\nThis email was sent through the contact form on your Zapfol.io site."

      mail.text_part { body content.strip }

      # Generate the html part now
      content = "<b>From:</b> <a href='mailto:#{args["from"]}'>#{args["from"]}</a><br>"
      args["fields"].each do |name, value|
        content << "<b>#{name}:</b> #{value == "" ? "[Empty]" : CGI::escapeHTML(value.gsub(/<br>$/, "")).gsub(/\r/, "").gsub("\n", "<br>")}<br>"
        content << "<br>" if value.length >= 150
      end

      content << "<br>-------------<br>This email was sent through the contact form on your Zapfol.io site."

      mail.html_part { content_type "text/html"; body content.gsub(/<br>$/, "") }

      mail.deliver!
    end
  end
end