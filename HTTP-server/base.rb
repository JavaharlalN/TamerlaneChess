require 'digest'

class User
    def initialize(login, password)
        if not /.{4,32}[a-zA-Z][0-9]*/.match(login)
            throw "invalid login"
        end
        @login = login
        if not /(?=.*[A-Z].*[A-Z])(?=.*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{8,32}/.match(password)
            throw "invalid password"
        end
        @password = Digest::SHA256.hexdigest password
        @registered_at = Time.now.to_i
        @last_online = Time.now.to_i
    end

    def auth?(password)
        hashed_pass = Digest::SHA256.hexdigest password
        if hashed_pass == @password
            return true
        end
        return false
    end

    def login
        @login
    end

    def registered_at
        @registered_at
    end

    def last_online
        @last_online
    end
end

class Base
    def initialize
        @users = []
    end

    def add(user)
        @users.push(user)
    end

    def find(login)
        return @users.find_all { |user| user.login == login }
    end

    def exists?(login)
        return !self.find(login).empty?
    end
end