Webhook::InboundController.class_eval do

  # Ensure that the olark integration is turned on and that the key passed is valid
  before_action(only: [:olark]) { enabled?('olark') }
  before_action(only: [:olark]) { check_token(AppSettings['webhook.olark_key']) }

  # curl -X POST http://helpy.local:3000/webhook/olark/50be1e6071ee4e4727f5977689598ca0/ --data-urlencode 'data={"kind": "Conversation", "tags": ["olark", "customer"], "items": [{"body": "Hi there. Need any help?", "timestamp": "1307116657.1", "kind": "MessageToVisitor", "nickname": "John", "operatorId": "1234"}, {"body": "Yes, please help me with billing.", "timestamp": "1307116661.25", "kind": "MessageToOperator", "nickname": "Bob"}], "operators": {"1234": {"username": "jdoe", "emailAddress": "john@example.com", "kind": "Operator", "nickname": "John", "id": "1234"}}, "groups": [{"kind": "Group", "name": "My Sales Group", "id": "0123456789abcdef"}], "visitor": {"ip": "123.4.56.78", "city": "Palo Alto", "kind": "Visitor", "conversationBeginPage": "http://www.example.com/path", "countryCode": "US", "country": "United State", "region": "CA", "chat_feedback": {"overall_chat": 5, "responsiveness": 5, "friendliness": 5, "knowledge": 5, "comments": "Very helpful, thanks"}, "operatingSystem": "Windows", "emailAddress": "steve@example.com", "organization": "Widgets Inc.", "phoneNumber": "(555) 555-5555", "fullName": "Steve Smith", "customFields": {"favoriteColor": "blue", "myInternalCustomerId": "12341234"}, "id": "9QRF9YWM5XW3ZSU7P9CGWRU89944341", "browser": "Chrome 12.1"}, "id": "EV695BI2930A6XMO32886MPT899443414"}'


  # {
  #     "kind": "Conversation",
  #     "id": "EV695BI2930A6XMO32886MPT899443414",
  #     "tags": ["olark", "customer"],
  #     "items": [{
  #         "kind": "MessageToVisitor",
  #         "nickname": "John",
  #         "timestamp": "1307116657.1",
  #         "body": "Hi there. Need any help?",
  #         "operatorId": "1234"
  #     },
  #     {
  #         "kind": "MessageToOperator",
  #         "nickname": "Bob",
  #         "timestamp": "1307116661.25",
  #         "body": "Yes, please help me with billing."
  #     }],
  #     "visitor": {
  #         "kind": "Visitor",
  #         "id": "9QRF9YWM5XW3ZSU7P9CGWRU89944341",
  #         "fullName": "Bob Doe",
  #         "emailAddress": "bob@example.com",
  #         "phoneNumber": "(555) 555-5555",
  #         "city": "Palo Alto",
  #         "region": "CA",
  #         "country": "United State",
  #         "countryCode": "US",
  #         "organization": "Widgets Inc.",
  #         "ip": "123.4.56.78",
  #         "browser": "Chrome 12.1",
  #         "operatingSystem": "Windows",
  #         "conversationBeginPage": "http://www.example.com/path",
  #         "customFields": {
  #             "myInternalCustomerId": "12341234",
  #             "favoriteColor": "blue"
  #         },
  #         "chat_feedback": {
  #             "comments": "Very helpful, thanks",
  #             "friendliness": 5,
  #             "knowledge": 5,
  #             "overall_chat": 5,
  #             "responsiveness": 5
  #         }
  #     },
  #     "operators": {
  #         "1234": {
  #             "kind": "Operator",
  #             "id": "1234",
  #             "username": "jdoe",
  #             "nickname": "John",
  #             "emailAddress": "john@example.com"
  #         }
  #     },
  #     "groups": [{
  #         "name": "My Sales Group",
  #         "id": "0123456789abcdef",
  #         "kind": "Group"
  #     }]
  # }


  def olark
    @params = JSON.parse(request.params[:data])

    # create topic and first post
    @topic = Topic.new(
      name: "New Chat with #{@params['visitor']['fullName']}",
      forum_id: 1,
      private: true,
      channel: 'chat',
      assigned_user_id: assigned_agent_id_from_chat,
      )

    if @topic.create_topic_with_olark_user(@params)
      @user = @topic.user
      @post = @topic.posts.create(
        body: create_body_from_chat,
        user_id: @user.id,
        kind: 'first',
        )
    end

    render json: @topic
  end

  def create_body_from_chat
    message = ""
    @params['items'].each do |item|
      message = message + "#{item['nickname']}: #{item['body']} \n"
    end
    return message
  end

  def assigned_agent_id_from_chat
    # because there can be multiple operators and only one assigned agent in
    # helpy, we'll take the first one we find
    agent = User.find_by_email(@params['operators'].first[1]['emailAddress']) if @params['operators'].present?
    if agent.nil?
      agent = User.find_by_name("System")
    end
    return agent.id
  end

end
