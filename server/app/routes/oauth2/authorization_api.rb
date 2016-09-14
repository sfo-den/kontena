module OAuth2Api
  # The authorization endpoint is the endpoint on the authorization server
  # where the resource owner logs in, and grants authorization to the client
  # application.
  #
  # response_type
  #    REQUIRED.  The value MUST be one of "code" for requesting an
  #    authorization code as described by Section 4.1.1, "token" for
  #    requesting an access token (implicit grant) as described by
  #    Section 4.2.1, or a registered extension value as described by
  #    Section 8.4.
  # https://tools.ietf.org/html/rfc6749#section-3.1.1
  class AuthorizationApi < Roda
    include RequestHelpers
    include TokenAuthenticationHelper
    include OAuth2Api::Common

    RESPONSE_TYPE      = 'response_type'.freeze
    CODE               = 'code'.freeze
    TOKEN              = 'token'.freeze
    INVITE             = 'invite'.freeze
    SCOPE              = 'scope'.freeze
    EMAIL              = 'email'.freeze
    NAME               = 'name'.freeze
    EXTERNAL_ID        = 'external_id'.freeze
    INVALID_SCOPE      = 'invalid_scope'.freeze
    EMAIL_REGEX        = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    EXPIRES_IN         = 'expires_in'.freeze
    USER               = 'user'
    AUTH_SHOW          = 'auth/show'.freeze
    ACCESS_DENIED      = 'access_denied'.freeze
    NO_PERM            = 'You do not have the permission to create invites'.freeze
    UNSUPPORTED        = 'unsupported_response_type'.freeze
    UNSUPPORTED_DESC   = 'Unsupported response type. Supported: code, token, invite'.freeze
    SERVER_ERROR       = 'server_error'.freeze
    NOT_ADMIN          = 'User not admin, denying access'.freeze

    route do |r|
      r.post do
        params = params_from_anywhere
        if params.nil? || params.empty?
          mime_halt(400, OAuth2Api::INVALID_REQUEST) and return
        end

        case params[RESPONSE_TYPE]
        when CODE, TOKEN
          validate_access_token(USER)
          unless params[SCOPE]
            mime_halt(400, INVALID_SCOPE) and return
          end

          task = AccessTokens::Create.run(
            user: current_user,
            scope: params[SCOPE],
            refreshable: params[EXPIRES_IN].to_i > 0,
            expires_in: params[EXPIRES_IN],
            with_code: params[RESPONSE_TYPE] == CODE
          )
          if task.success?
            response.status = 201
            @access_token = task.result
            render(AUTH_SHOW)
          else
            mime_halt(400, OAuth2Api::INVALID_REQUEST, task.errors.message.inspect) and return
          end
        when INVITE

          task = Users::Invite.run(
            user: current_user,
            email: params[EMAIL],
            name: params[NAME] || params[EMAIL],
            external_id: params[EXTERNAL_ID],
            with_invite: true
          )

          unless task.success?
            mime_halt(400, Oauth2Api::INVALID_REQUEST, task.errors.message.inspect) and return
          end

          @user = task.result

          if @user
            response.status = 201
            uri = URI.parse("#{env['rack.url_scheme']}://#{request.host}")
            uri.port = request.port unless [80, 443].include?(request.port)
            uri.path = "/j/#{user.invite_code}"
            @link = uri.to_s
            @user = user
            render('users/invite')
          else
            mime_halt(500, SERVER_ERROR, user.errors.inspect) and return
          end
        else
          mime_halt(400, UNSUPPORTED, UNSUPPORTED_DESC) and return
        end
      end
    end
  end
end

