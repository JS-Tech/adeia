class TokenTable < BaseTable

  def model
    Adeia::Token
  end

  def attributes
    [:id, :adeia_permission_id, :is_valid, :exp_at, :created_at, :updated_at]
  end

end
