module Api::Nextcrm::V1::Concerns::Filterable
  extend ActiveSupport::Concern




  def filterToElasticSearchQuery(filter)
    ret_query = ""
    attributes = filter.keys
    attributes.each do |att|
      operator = filter[att].keys[0]
      value = filter[att][operator] 

      if att.include? "email"
        # check if email in filter is a linked email
        linked_authorization = Authorization.where(email: value).last
        if linked_authorization
          user = User.where(id: linked_authorization.user_id).last
          if user and user.email
            value = user.email
          end
        end
      end

      case operator
        when "eq"
          ret_query += "#{att}:#{value} AND "
        when "ci"
          ret_query += "#{att}:*#{value}* AND "
        when "si"
          ret_query += "#{att}:#{value}* AND "
        when "ei"
          ret_query += "#{att}:*#{value} AND "
        else
          next
      end
    end
    ret_query.strip!.delete_suffix!("AND")
    return ret_query
  end


  



end