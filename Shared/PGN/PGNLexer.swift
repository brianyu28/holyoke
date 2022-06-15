// Generated from PGN.g4 by ANTLR 4.10.1
import Antlr4

open class PGNLexer: Lexer {

    internal static var _decisionToDFA: [DFA] = {
          var decisionToDFA = [DFA]()
          let length = PGNLexer._ATN.getNumberOfDecisions()
          for i in 0..<length {
                  decisionToDFA.append(DFA(PGNLexer._ATN.getDecisionState(i)!, i))
          }
           return decisionToDFA
     }()

    internal static let _sharedContextCache = PredictionContextCache()

    public
    static let WHITE_WINS=1, BLACK_WINS=2, DRAWN_GAME=3, REST_OF_LINE_COMMENT=4,
            BRACE_COMMENT=5, ESCAPE=6, SPACES=7, STRING=8, INTEGER=9, PERIOD=10,
            ASTERISK=11, LEFT_BRACKET=12, RIGHT_BRACKET=13, LEFT_PARENTHESIS=14,
            RIGHT_PARENTHESIS=15, LEFT_ANGLE_BRACKET=16, RIGHT_ANGLE_BRACKET=17,
            NUMERIC_ANNOTATION_GLYPH=18, SYMBOL=19, SUFFIX_ANNOTATION=20,
            UNEXPECTED_CHAR=21

    public
    static let channelNames: [String] = [
        "DEFAULT_TOKEN_CHANNEL", "HIDDEN"
    ]

    public
    static let modeNames: [String] = [
        "DEFAULT_MODE"
    ]

    public
    static let ruleNames: [String] = [
        "WHITE_WINS", "BLACK_WINS", "DRAWN_GAME", "REST_OF_LINE_COMMENT", "BRACE_COMMENT",
        "ESCAPE", "SPACES", "STRING", "INTEGER", "PERIOD", "ASTERISK", "LEFT_BRACKET",
        "RIGHT_BRACKET", "LEFT_PARENTHESIS", "RIGHT_PARENTHESIS", "LEFT_ANGLE_BRACKET",
        "RIGHT_ANGLE_BRACKET", "NUMERIC_ANNOTATION_GLYPH", "SYMBOL", "SUFFIX_ANNOTATION",
        "UNEXPECTED_CHAR"
    ]

    private static let _LITERAL_NAMES: [String?] = [
        nil, "'1-0'", "'0-1'", "'1/2-1/2'", nil, nil, nil, nil, nil, nil, "'.'",
        "'*'", "'['", "']'", "'('", "')'", "'<'", "'>'"
    ]
    private static let _SYMBOLIC_NAMES: [String?] = [
        nil, "WHITE_WINS", "BLACK_WINS", "DRAWN_GAME", "REST_OF_LINE_COMMENT",
        "BRACE_COMMENT", "ESCAPE", "SPACES", "STRING", "INTEGER", "PERIOD", "ASTERISK",
        "LEFT_BRACKET", "RIGHT_BRACKET", "LEFT_PARENTHESIS", "RIGHT_PARENTHESIS",
        "LEFT_ANGLE_BRACKET", "RIGHT_ANGLE_BRACKET", "NUMERIC_ANNOTATION_GLYPH",
        "SYMBOL", "SUFFIX_ANNOTATION", "UNEXPECTED_CHAR"
    ]
    public
    static let VOCABULARY = Vocabulary(_LITERAL_NAMES, _SYMBOLIC_NAMES)


    override open
    func getVocabulary() -> Vocabulary {
        return PGNLexer.VOCABULARY
    }

    public
    required init(_ input: CharStream) {
        RuntimeMetaData.checkVersion("4.10.1", RuntimeMetaData.VERSION)
        super.init(input)
        _interp = LexerATNSimulator(self, PGNLexer._ATN, PGNLexer._decisionToDFA, PGNLexer._sharedContextCache)
    }

    override open
    func getGrammarFileName() -> String { return "PGN.g4" }

    override open
    func getRuleNames() -> [String] { return PGNLexer.ruleNames }

    override open
    func getSerializedATN() -> [Int] { return PGNLexer._serializedATN }

    override open
    func getChannelNames() -> [String] { return PGNLexer.channelNames }

    override open
    func getModeNames() -> [String] { return PGNLexer.modeNames }

    override open
    func getATN() -> ATN { return PGNLexer._ATN }

    override open
    func sempred(_ _localctx: RuleContext?, _  ruleIndex: Int,_   predIndex: Int) throws -> Bool {
        switch (ruleIndex) {
        case 5:
            return try ESCAPE_sempred(_localctx?.castdown(RuleContext.self), predIndex)
        default: return true
        }
    }
    private func ESCAPE_sempred(_ _localctx: RuleContext!,  _ predIndex: Int) throws -> Bool {
        switch (predIndex) {
            case 0:return getCharPositionInLine() == 0
            default: return true
        }
    }

    static let _serializedATN:[Int] = [
        4,0,21,145,6,-1,2,0,7,0,2,1,7,1,2,2,7,2,2,3,7,3,2,4,7,4,2,5,7,5,2,6,7,
        6,2,7,7,7,2,8,7,8,2,9,7,9,2,10,7,10,2,11,7,11,2,12,7,12,2,13,7,13,2,14,
        7,14,2,15,7,15,2,16,7,16,2,17,7,17,2,18,7,18,2,19,7,19,2,20,7,20,1,0,1,
        0,1,0,1,0,1,1,1,1,1,1,1,1,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,1,3,5,3,
        62,8,3,10,3,12,3,65,9,3,1,4,1,4,5,4,69,8,4,10,4,12,4,72,9,4,1,4,1,4,1,
        5,1,5,1,5,5,5,79,8,5,10,5,12,5,82,9,5,1,5,1,5,1,6,4,6,87,8,6,11,6,12,6,
        88,1,6,1,6,1,7,1,7,1,7,1,7,1,7,1,7,5,7,99,8,7,10,7,12,7,102,9,7,1,7,1,
        7,1,8,4,8,107,8,8,11,8,12,8,108,1,9,1,9,1,10,1,10,1,11,1,11,1,12,1,12,
        1,13,1,13,1,14,1,14,1,15,1,15,1,16,1,16,1,17,1,17,4,17,129,8,17,11,17,
        12,17,130,1,18,1,18,5,18,135,8,18,10,18,12,18,138,9,18,1,19,1,19,3,19,
        142,8,19,1,20,1,20,0,0,21,1,1,3,2,5,3,7,4,9,5,11,6,13,7,15,8,17,9,19,10,
        21,11,23,12,25,13,27,14,29,15,31,16,33,17,35,18,37,19,39,20,41,21,1,0,
        8,2,0,10,10,13,13,1,0,125,125,3,0,9,10,13,13,32,32,2,0,34,34,92,92,1,0,
        48,57,3,0,48,57,65,90,97,122,8,0,35,35,43,43,45,45,48,58,61,61,65,90,95,
        95,97,122,2,0,33,33,63,63,155,0,1,1,0,0,0,0,3,1,0,0,0,0,5,1,0,0,0,0,7,
        1,0,0,0,0,9,1,0,0,0,0,11,1,0,0,0,0,13,1,0,0,0,0,15,1,0,0,0,0,17,1,0,0,
        0,0,19,1,0,0,0,0,21,1,0,0,0,0,23,1,0,0,0,0,25,1,0,0,0,0,27,1,0,0,0,0,29,
        1,0,0,0,0,31,1,0,0,0,0,33,1,0,0,0,0,35,1,0,0,0,0,37,1,0,0,0,0,39,1,0,0,
        0,0,41,1,0,0,0,1,43,1,0,0,0,3,47,1,0,0,0,5,51,1,0,0,0,7,59,1,0,0,0,9,66,
        1,0,0,0,11,75,1,0,0,0,13,86,1,0,0,0,15,92,1,0,0,0,17,106,1,0,0,0,19,110,
        1,0,0,0,21,112,1,0,0,0,23,114,1,0,0,0,25,116,1,0,0,0,27,118,1,0,0,0,29,
        120,1,0,0,0,31,122,1,0,0,0,33,124,1,0,0,0,35,126,1,0,0,0,37,132,1,0,0,
        0,39,139,1,0,0,0,41,143,1,0,0,0,43,44,5,49,0,0,44,45,5,45,0,0,45,46,5,
        48,0,0,46,2,1,0,0,0,47,48,5,48,0,0,48,49,5,45,0,0,49,50,5,49,0,0,50,4,
        1,0,0,0,51,52,5,49,0,0,52,53,5,47,0,0,53,54,5,50,0,0,54,55,5,45,0,0,55,
        56,5,49,0,0,56,57,5,47,0,0,57,58,5,50,0,0,58,6,1,0,0,0,59,63,5,59,0,0,
        60,62,8,0,0,0,61,60,1,0,0,0,62,65,1,0,0,0,63,61,1,0,0,0,63,64,1,0,0,0,
        64,8,1,0,0,0,65,63,1,0,0,0,66,70,5,123,0,0,67,69,8,1,0,0,68,67,1,0,0,0,
        69,72,1,0,0,0,70,68,1,0,0,0,70,71,1,0,0,0,71,73,1,0,0,0,72,70,1,0,0,0,
        73,74,5,125,0,0,74,10,1,0,0,0,75,76,4,5,0,0,76,80,5,37,0,0,77,79,8,0,0,
        0,78,77,1,0,0,0,79,82,1,0,0,0,80,78,1,0,0,0,80,81,1,0,0,0,81,83,1,0,0,
        0,82,80,1,0,0,0,83,84,6,5,0,0,84,12,1,0,0,0,85,87,7,2,0,0,86,85,1,0,0,
        0,87,88,1,0,0,0,88,86,1,0,0,0,88,89,1,0,0,0,89,90,1,0,0,0,90,91,6,6,0,
        0,91,14,1,0,0,0,92,100,5,34,0,0,93,94,5,92,0,0,94,99,5,92,0,0,95,96,5,
        92,0,0,96,99,5,34,0,0,97,99,8,3,0,0,98,93,1,0,0,0,98,95,1,0,0,0,98,97,
        1,0,0,0,99,102,1,0,0,0,100,98,1,0,0,0,100,101,1,0,0,0,101,103,1,0,0,0,
        102,100,1,0,0,0,103,104,5,34,0,0,104,16,1,0,0,0,105,107,7,4,0,0,106,105,
        1,0,0,0,107,108,1,0,0,0,108,106,1,0,0,0,108,109,1,0,0,0,109,18,1,0,0,0,
        110,111,5,46,0,0,111,20,1,0,0,0,112,113,5,42,0,0,113,22,1,0,0,0,114,115,
        5,91,0,0,115,24,1,0,0,0,116,117,5,93,0,0,117,26,1,0,0,0,118,119,5,40,0,
        0,119,28,1,0,0,0,120,121,5,41,0,0,121,30,1,0,0,0,122,123,5,60,0,0,123,
        32,1,0,0,0,124,125,5,62,0,0,125,34,1,0,0,0,126,128,5,36,0,0,127,129,7,
        4,0,0,128,127,1,0,0,0,129,130,1,0,0,0,130,128,1,0,0,0,130,131,1,0,0,0,
        131,36,1,0,0,0,132,136,7,5,0,0,133,135,7,6,0,0,134,133,1,0,0,0,135,138,
        1,0,0,0,136,134,1,0,0,0,136,137,1,0,0,0,137,38,1,0,0,0,138,136,1,0,0,0,
        139,141,7,7,0,0,140,142,7,7,0,0,141,140,1,0,0,0,141,142,1,0,0,0,142,40,
        1,0,0,0,143,144,9,0,0,0,144,42,1,0,0,0,11,0,63,70,80,88,98,100,108,130,
        136,141,1,6,0,0
    ]

    public
    static let _ATN: ATN = try! ATNDeserializer().deserialize(_serializedATN)
}
