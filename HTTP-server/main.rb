require 'socket'
require 'json'
require './base'

class ResponseManager
    def initialize
        @status = "HTTP/1.1 200 OK"
        @content = "{}"
    end

    def write_content(content)
        @content = content
    end

    def set_status(code)
        case code
        when 200
            @status = "HTTP/1.1 200 OK"
        when 400
            @status = "HTTP/1.1 400 BAD REQUEST"
        when 403
            @status = "HTTP/1.1 403 FORBIDDEN"
        when 404
            @status = "HTTP/1.1 404 NOT FOUND"
        when 405
            @status = "HTTP/1.1 405 METHOD NOT ALLOWED"
        when 418
            @status = "HTTP/1.1 418 I'M A TEAPOT"
        else
            @status = "HTTP/1.1 500 INTERNAL SERVER ERROR"
        end
    end

    def write_err(message, code=400)
        @content = "{'err':'#{message}'}"
        self.set_status(code)
    end

    def send_to(client)
        client.print @status + "\r\n"
        client.print "ngrok-skip-browser-warning: 565354\r\n"
        client.print "Content-Type: application/json\r\n"
        client.print "Content-Length: #{@content.length}\r\n"
        client.print "\r\n"
        client.print @content
        client.close
    end
end

server = TCPServer.open(4756)
base = Base.new

while session = server.accept
    method, path = session.gets.split                    # In this case, method = "POST" and path = "/"
    path = path.split('/').reject { |s| s.empty? }
    headers = {}
    while line = session.gets.split(' ', 2)              # Collect HTTP headers
        break if line[0] == ""                            # Blank line means no more headers
        headers[line[0].chop] = line[1].strip             # Hash headers by type
    end
    data = session.read(headers["Content-Length"].to_i)  # Read the POST data as specified in the header
    response_manager = ResponseManager.new

    case method
    when "GET"
        case path[0]
        when "users"
            login = path[1]
            res = base.find login
            if res.empty?
                response_manager.write_err("user `#{login}` not found", 404)
            else
                response_manager.write_content(JSON.generate({
                    login: login,
                    registered_at: res[0].registered_at,
                    last_online: res[0].last_online,
                }))
            end
        when "signin"
            login = path[1]
            password = path[2]
            res = base.find login
            if res.empty?
                response_manager.write_err("user `#{login}` not found", 404)
            elsif !res[0].auth?(password)
                response_manager.write_err("invalid password", 403)
            end
        when "signup"
            response_manager.write_err("use POST method")
        else
            response_manager.write_err("unknown section")
        end
    when "POST"
        case path[0]
        when "signin", "users"
            response_manager.write_err("use GET method")
        when "signup"
            data_json = JSON.parse(data)
            login = data_json["login"]
            if base.exists?(login)
                response_manager.write_err("user with login `#{login}` already exists")
            else
                begin
                    user = User.new(login, data_json["password"])
                    base.add user
                    p "New user! #{login}"
                    response_manager.write_content(JSON.generate({
                        login: user.login,
                        registered_at: user.registered_at,
                        last_online: user.last_online,
                    }))
                rescue StandardError => exception
                    response_manager.write_err(exception)
                end
            end
        else
            response_manager.write_err("unknown section")
        end
        # p path
        # puts data + "\n\n"
    else
        response_manager.write_err "unknown method: #{method}", 405
    end


    response_manager.send_to session
#   headers.each do |key, value|
#     session.print "#{key}: #{value}\r\n"
#   end
end