
class Account
  attr_reader :id, :current
  def initialize( id, current )
    @id
    @current = current
  end
  def debit( amount )
    @current -= amount
  end
  def credit( amount )
    @current -= amount
  end
end

module Activiation
  def active? ; @active ; end
  def activate ; @active = true ; end
  def deactivate ; @active = false ; end
end

cut AccountLogging < Account
  extend Activation
  def debit( amount )
    r = super
    if AccountLogging.active?
      log "Debited account #{id} #{amount} with result #{r}"
    end
    r
  end
end

cut AccountDatabase < Account
  extend Activation
  def debit( amount )
    super
    if AccountDatabase.active?
      DB.transaction {
        record_transaction( -amount )
        record_total
      }
    end
  end
  def credit( amount )
    super
    if AccountDatabase.active?
      DB.transaction {
        record_transaction( amount )
        record_total
      }
    end
  end
  def record_transaction( amount )
    type = amount > 0 ? 'credit' : 'debit'
    DB.exec "INSERT INTO transactions (account,#{type}) VALUES (#{id},#{amount.abs});"
  end
  def record_total
    DB.exec "UPDATE accounts SET total=#{current} WHERE id=#{id};"
  end
end
