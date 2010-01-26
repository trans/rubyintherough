#
# A Foo FTPServer Demo for dynaop.rb
#

require 'aop/tag'
require 'aop/dynaop'


class FTPServer

  def login(username, passwd)
    # code for logging in, return ID for the connection
    connID = username
    return connID
  end

  def logout(connID)
    # code for logging out
  end

  def upload(connID, filename, data)
    # code for writing a file
  end

  def download(connID, finename)
    # code for reading a file, returns the data read
    return "Pretend File"
  end

end


FTPServer.tag :login => [ :do_login ],
              :logout => [ :do_logout, :after_login ],
              :upload => [ :after_login ],
              :download => [ :after_login ]

                            
class LoginSecurity < AOP::Weaving::Aspect
  
  # PROBLEM!!!
  # Here's a problem! B/c dynaop.rb can't do
  # true method dispatching like reaop.rb can,
  # we can't invoke multiple advice per call.
  # Hence :logout cannot invoke :after_login. :(
  def crosscut( jp )
    lgmeths = jp.klass.tags[ jp.meth.intern ]
    if lgmeths
      return lgmeths[0]  # <- Notice the index :(
    end
  end
   
  def initialize
    @logged_in = {}
  end
  
  def after_login(target, connID, *args)
    raise LoginException.new unless @logged_in[connID]
    puts "Acknowledged for #{target.called}: #{connID} on #{args.join(',')}."
    target.call(connID, *args) #super
  end
          
  def do_login(target, *args)
    connID = target.call(*args) #super
    @logged_in[connID] = true
    puts "New Session: #{connID}."
    #result
  end
  passive :do_login
    
  def do_logout(target, *args)
    connID = target.call(*args) #super
    @logged_in[connID] = nil # or false
  end

end

security = LoginSecurity.weave

ftps = FTPServer.new
connID = ftps.login('tom', 'pencil')
upfile = ftps.download(connID, 'tomsfile.rb')

