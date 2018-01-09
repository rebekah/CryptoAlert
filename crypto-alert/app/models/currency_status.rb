class CurrencyStatus < ActiveRecord::Base
  COMPARATORS = {"ETH" => "USD", "NEO" => "ETH"}

  def self.check
    ["NEO","ETH"].each do |symbol|
      response_json = `curl "https://min-api.cryptocompare.com/data/price?fsym=#{symbol}&tsyms=ETH,USD"`
      response = JSON.parse(response_json)
      if alert?(symbol, response)
        send_text_alert(symbol, response)
        update_db(symbol, response)
      end
    end
  end

  def self.alert?(symbol, response)
    if symbol == "ETH"
      last_value = CurrencyStatus.where(symbol: "ETH", comparator: "USD").last.try(:value) || 0
      puts "current value for ETH is #{response["USD"]}"
      (response["USD"] - last_value).abs >= 5
    elsif symbol == "NEO"
      last_value = CurrencyStatus.where(symbol: "NEO", comparator: "ETH").last.try(:value) || 0
      puts "current value for NEO is #{response["ETH"]}"
      (response["ETH"] - last_value).abs >= 0.005
      false
    end
  end

  def self.send_text_alert(symbol, response)
    value = current_value(symbol, response)
    message = "The currency with symbol: #{symbol} is now at value: #{value} in comparison with #{COMPARATORS[symbol]}."
    `curl 'https://api.twilio.com/2010-04-01/Accounts/AC49be723e6f26c1adaee0ef9aa94c2c3e/Messages.json' -X POST \
      --data-urlencode 'To=<Your Phone Number>' \
      --data-urlencode 'From=<Your Twilio Phone Number>' \
      --data-urlencode 'Body=#{message}' \
      -u <Twilio Account>:<Twilio Auth Token>`
  end

  def self.current_value(symbol, response)
   comparator = COMPARATORS[symbol]
   response[comparator]
  end

  def self.update_db(symbol, response)
    response.each do |comparator, value|
      self.create(symbol: symbol, comparator: comparator, value: value.to_f)
    end
  end

  def self.send_call_alert
    account_sid = '<Twilio Account>'
    auth_token = '<Twilio Auth Token>'
    @client = Twilio::REST::Client.new account_sid, auth_token

    @call = @client.calls.create(
      :from => '<Your Twilio Phone Number>',
      :to => '<Your Phone Number>',
      :url => 'http://twimlets.com/holdmusic?Bucket=com.twilio.music.ambient'
    )
  end
end