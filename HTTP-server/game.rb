DEFAULT_FEN = "e1c1w1w1c1e/rnbgmkvgbnr/-r-n-b-g-m-k-v-e-c-w-p/11/11/11/11/-P-W-C-E-V-K-M-G-B-N-R/rnbgvkmgbnr/e1c1w1w1c1e"

class Move
    def initialize(piece, x0, y0, x, y, action)
        @code   = ""
        @action = nil
        @x0     = x0
        @y0     = y0
        @x      = x
        @y      = y
        @piece  = piece

        case piece
        when 0, 'e'    # elephant
            @code += 'E'
        when 1, 'c'    # camel
            @code += 'C'
        when 2, 'w'    # war engine / mann
            @code += 'W'
        when 3, 'r'    # rook
            @code += 'R'
        when 4, 'n'    # knight
            @code += 'N'
        when 5, 'b'    # bishop
            @code += 'B'
        when 6, 'g'    # giraffe
            @code += 'G'
        when 7, 'm'    # minister
            @code += 'M'
        when 8, 'k'    # king
            @code += 'K'
        when 9, 'v'    # vizier
            @code += 'V'
        when 10, 'rp'  # rook pawn
            @code += 'r'
        when 11, 'np'  # knight pawn
            @code += 'n'
        when 12, 'gp'  # giraffe pawn
            @code += 'g'
        when 13, 'mp'  # minister pawn
            @code += 'm'
        when 14, 'kp'  # king pawn
            @code += 'k'
        when 15, 'vp'  # vizier pawn
            @code += 'v'
        when 16, 'ep'  # elephant pawn
            @code += 'e'
        when 17, 'cp'  # camel pawn
            @code += 'c'
        when 18, 'wp'  # war pawn
            @code += 'w'
        when 19, 'pp'  # pawn pawn
            @code += 'p'
        else
            throw "invalid piece code"
        end

        if action == 1  # 0 - just move, 1 - capture
            @code += 'x'
        end

        unless "abcdefghijk".include? x0 and "abcdefghijk".include? x
            throw "invalid coordinates (x0: #{x0}, x1: #{x1})"
        end
        @code += x0

        if (0..10).include? y0 and (0..10).include? y
            if x0 != x and y0 != y
                @code += y0.to_s + x
            elsif x0 != x
                @code += x
            end
            @code += y0.to_s
            if y0 != y and x0 == x
                @code += y.to_s
            end
        end

        case move
        when 2
            @code += '+'
            @action = "check"
        when 3
            @code += '#'
            @action = "mate"
        when 4  # pawn promotion
            @code += '!'
            @action = "promotion"
        when 5  # stalemate or draw
            @code += '-'
            @action = "draw"
        end
    end
end

class Pair
    def initialize(move=nil)
        @white = move
        @black = nil
    end

    def black
        @black
    end

    def white
        @white
    end

    def black=(move)
        @black = move
    end

    def white=(move)
        @white = move
    end

    def full?
        !@white.nil? and !@black.nil?
    end

    def add(move)
        if @white.nil?
            @white = move
        elsif @black.nil?
            @black = move
        end
    end
end

class History
    def initialize(fen)
        @fen = fen
        @moves = []
    end

    def add(move)
        if @moves.last.full?
            @moves.push Pair.new move
        else
            @moves.last.add move
        end
    end
end

class Game
    def initialize(black, white, fen=DEFAULT_FEN)
        @black   = black  # user
        @white   = white  # user
        @turn    = 0      # 0 - white, 1 - black
        @started = Time.now.to_i
        @history = History.new fen
    end

    def white_turn?
        return @turn == 0
    end

    def black_turn?
        return @turn == 1
    end

    def move(piece, x0, y0, x, y, action=0)
        @history.add Move.new(piece, x0, y0, x, y, action)
    end
end