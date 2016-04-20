module Blog

  class UserRegistration < Action

    attr_accessor :authorization_credentials, :designer

    def initialize(designer)
      self.authorization_credentials = { username: Settings.blog.api.username, password: Settings.blog.api.password }
      self.designer = designer
    end

    def perform
      do_request
      store_registration_result
      fail_if_not_created
    end

    private

    def fail_if_not_created
      fail(@response.status.to_s + ' ' + @response.body) unless @response.status == 201 #created
    end

    def store_registration_result
      designer.update_attributes(blog_account_json: @response.body,
                                 blog_password: password,
                                 blog_username: username)
    end

    def password
      designer.plain_password
    end

    def username
      designer.email
    end

    def generate_user_info
      {
        username: username,
        name: designer.name,
        first_name: designer.first_name,
        last_name: designer.last_name,
        email: designer.email,
        password: password
      }
    end

    def do_request
      connection = Faraday.new(url: Settings.blog.api.path)
      connection.basic_auth(authorization_credentials[:username], authorization_credentials[:password])
      @response = connection.post('users', generate_user_info)
    end

  end

end
