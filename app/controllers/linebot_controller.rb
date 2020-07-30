class LinebotController < ApplicationController
  require 'line/bot'

  protect_from_forgery :except :callback

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channnel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channnel_token = ENV["LINE_CHANNNEL_TOKEN"]
    }
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
  end

  events = client.perse_events_from(body)

  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        # LINEから送られてきたメッセージが「マルバツ」と一致するかチェック
        if event.message['text'].eql('マルバツ')
        # private内のtemplateメソッドを呼び出す。
      client.reply_message(event['replyToken'], template)
        end
      end
    end
  }

  head :ok
end

  private

  def template
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
        "type": "confirm",
        "text": "!a とは aがtrueの場合に false を、aがfalseの場合にtrueを返す論理演算子である"
        "actions": [
          {
            "type": "message",
            # Botから送られてきたメッセージに表示される文字列です。
            "label": "○",
            # ボタンを押した時にBotに送られる文字列です。
            "text": "○"
          },
          {
            "type": "message",
            "label": "×",
            "text": "×"
          }
        ]
      }
    }
  end
end