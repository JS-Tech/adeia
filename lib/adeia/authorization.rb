require 'adeia/database'
require 'adeia/exceptions'

module Adeia

  class Authorization < Database

    def authorize!
      @rights = token_rights(right_name)
      raise LoginRequired if @rights.empty? && @user.nil?
      @rights.push(send("#{right_name}_rights")) if @user
      raise AccessDenied unless authorize?
    end

    def can?
      @rights = token_rights.push(send("#{right_name}_rights"))
      authorize?
    end

    private

    def authorize?
      all_entries? || on_ownerships? || on_entry?
    end

    def all_entries?
      @rights.any? { |r| r.permission_type == "all_entries" }
    end

    def on_ownerships?
      @rights.any? { |r| r.permission_type == "on_ownerships" } && @user && @resource.try(:user) == @user
    end

    def on_entry?
      @rights.pluck(:resource_id).compact.include? @resource.try(:id)
    end

    def right_names
      {read: [:index, :show], create: [:new, :create], update: [:edit, :update], destroy: [:destroy]} 
    end

    def right_name
      right_names.select { |k, v| v.include? @action.to_sym }.keys[0] || :action
    end

  end

end