# frozen_string_literal: true

module Secured
  def authenticate_user!
    # Bearer 'token'
    token_regex = /Bearer (\w+)/
    # leer de auth
    headers = request.headers
    # verificar
    if headers['Authorization'].present? && headers['Authorization'].match(token_regex)
      token = headers['Authorization'].match(token_regex)[1]
      # autorizar, negar
      return if (Current.user = User.find_by_auth_token(token))
    end

    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
