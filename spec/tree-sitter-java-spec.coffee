{TextEditor} = require 'atom'

describe 'Tree-sitter based Java grammar', ->
  grammar = null
  editor = null
  buffer = null

  beforeEach ->
    atom.config.set('core.useTreeSitterParsers', true)

    waitsForPromise ->
      atom.packages.activatePackage('language-java')

    runs ->
      editor = new TextEditor()
      grammar = atom.grammars.grammarForScopeName('source.java')
      editor.setGrammar(grammar)
      buffer = editor.getBuffer()

  # Compatibility functions with TextMate grammar tests

  # Returns list of tokens as [{value: ..., scopes: [...]}, ...]
  getTokens = (buffer, row) ->
    line = buffer.lineForRow row
    tokens = []

    iterator = buffer.getLanguageMode().buildHighlightIterator()
    start = {row: row, column: 0}
    scopes = iterator.seek(start, row)

    while true
      end = iterator.getPosition()

      if end.row > row
        end.row = row
        end.column = line.length

      if end.column > start.column
        tokens.push({
          value: line.substring(start.column, end.column),
          scopes: buffer.getLanguageMode().grammar.scopeNameForScopeId(s) for s in scopes
        })

      if end.column < line.length
        for num in iterator.getCloseScopeIds()
          item = scopes.pop()
        scopes.push(iterator.getOpenScopeIds()...)
        start = end
        iterator.moveToSuccessor()
      else
        break

    tokens

  tokenizeLine = (text) ->
    buffer.setText(text)
    getTokens(buffer, 0)

  tokenizeLines = (text) ->
    buffer.setText(text)
    lines = buffer.getLines()
    tokens = []
    row = 0
    for _ in lines
      tokens.push(getTokens(buffer, row))
      row += 1
    tokens

  # Unit tests

  fit 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.java'

  fit 'tokenizes punctuation', ->
    tokens = tokenizeLine 'int a, b, c;'

    expect(tokens[2]).toEqual value: ',', scopes: ['source.java', 'punctuation.separator.delimiter']
    expect(tokens[4]).toEqual value: ',', scopes: ['source.java', 'punctuation.separator.delimiter']
    expect(tokens[6]).toEqual value: ';', scopes: ['source.java', 'punctuation.terminator.statement']

    tokens = tokenizeLine 'a.b.c();'

    expect(tokens[1]).toEqual value: '.', scopes: ['source.java', 'punctuation.separator.period']
    expect(tokens[3]).toEqual value: '.', scopes: ['source.java', 'punctuation.separator.period']
    expect(tokens[7]).toEqual value: ';', scopes: ['source.java', 'punctuation.terminator.statement']

    tokens = tokenizeLine 'new com.package.Clazz();'

    expect(tokens[3]).toEqual value: '.', scopes: ['source.java', 'punctuation.separator.period']
    expect(tokens[5]).toEqual value: '.', scopes: ['source.java', 'punctuation.separator.period']
    expect(tokens[9]).toEqual value: ';', scopes: ['source.java', 'punctuation.terminator.statement']

  fit 'tokenizes instanceof', ->
    tokens = tokenizeLine 'a instanceof A'

    expect(tokens[1]).toEqual value: 'instanceof', scopes: ['source.java', 'keyword.operator.instanceof']

  fit 'tokenizes comparison', ->
    tokens = tokenizeLines '''
      a > b;
      a < b;
      a == b;
      a >= b;
      a <= b;
      a != b;
    '''

    expect(tokens[0][1]).toEqual value: '>', scopes: ['source.java', 'keyword.operator.comparison']
    expect(tokens[1][1]).toEqual value: '<', scopes: ['source.java', 'keyword.operator.comparison']
    expect(tokens[2][1]).toEqual value: '==', scopes: ['source.java', 'keyword.operator.comparison']
    expect(tokens[3][1]).toEqual value: '>=', scopes: ['source.java', 'keyword.operator.comparison']
    expect(tokens[4][1]).toEqual value: '<=', scopes: ['source.java', 'keyword.operator.comparison']
    expect(tokens[5][1]).toEqual value: '!=', scopes: ['source.java', 'keyword.operator.comparison']

  fit 'tokenizes logical', ->
    tokens = tokenizeLines '''
      a && b;
      a || b;
      !a;
    '''

    expect(tokens[0][1]).toEqual value: '&&', scopes: ['source.java', 'keyword.operator.logical']
    expect(tokens[1][1]).toEqual value: '||', scopes: ['source.java', 'keyword.operator.logical']
    expect(tokens[2][0]).toEqual value: '!', scopes: ['source.java', 'keyword.operator.logical']

  fit 'tokenizes arithmetic', ->
    tokens = tokenizeLines '''
      a + b;
      a - b;
      a * b;
      a / b;
      a % b;
      a += b;
      a -= b;
      a *= b;
      a /= b;
      a %= b;
      a++;
      --a;
    '''

    expect(tokens[0][1]).toEqual value: '+', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[1][1]).toEqual value: '-', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[2][1]).toEqual value: '*', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[3][1]).toEqual value: '/', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[4][1]).toEqual value: '%', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[5][1]).toEqual value: '+=', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[6][1]).toEqual value: '-=', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[7][1]).toEqual value: '*=', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[8][1]).toEqual value: '/=', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[9][1]).toEqual value: '%=', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[10][1]).toEqual value: '++', scopes: ['source.java', 'keyword.operator.arithmetic']
    expect(tokens[11][0]).toEqual value: '--', scopes: ['source.java', 'keyword.operator.arithmetic']

  fit 'tokenizes bitwise', ->
    tokens = tokenizeLines '''
      a & b;
      a | b;
      a ^ b;
      a >> b;
      a << b;
      a >>> b;
      a &= b;
      a |= b;
      a ^= b;
      a >>= b;
      a <<= b;
      a >>>= b;
      ~a;
    '''

    expect(tokens[0][1]).toEqual value: '&', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[1][1]).toEqual value: '|', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[2][1]).toEqual value: '^', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[3][1]).toEqual value: '>>', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[4][1]).toEqual value: '<<', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[5][1]).toEqual value: '>>>', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[6][1]).toEqual value: '&=', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[7][1]).toEqual value: '|=', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[8][1]).toEqual value: '^=', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[9][1]).toEqual value: '>>=', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[10][1]).toEqual value: '<<=', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[11][1]).toEqual value: '>>>=', scopes: ['source.java', 'keyword.operator.bitwise']
    expect(tokens[12][0]).toEqual value: '~', scopes: ['source.java', 'keyword.operator.bitwise']

  fit 'tokenizes brackets', ->
    tokens = tokenizeLine '{ (a + b) + c[d] }'

    expect(tokens[0]).toEqual value: '{', scopes: ['source.java', 'punctuation.bracket.curly']
    expect(tokens[2]).toEqual value: '(', scopes: ['source.java', 'punctuation.bracket.round']
    expect(tokens[6]).toEqual value: ')', scopes: ['source.java', 'punctuation.bracket.round']
    expect(tokens[10]).toEqual value: '[', scopes: ['source.java', 'punctuation.bracket.square']
    expect(tokens[12]).toEqual value: ']', scopes: ['source.java', 'punctuation.bracket.square']
    expect(tokens[14]).toEqual value: '}', scopes: ['source.java', 'punctuation.bracket.curly']

  fit 'tokenizes spread parameters', ->
    tokens = tokenizeLine 'public void method(String... args) { }'

    expect(tokens[5]).toEqual value: '...', scopes: ['source.java', 'punctuation.definition.parameters.varargs']

  fit 'tokenizes this and super', ->
    tokens = tokenizeLine 'this.x + super.x;'

    expect(tokens[0]).toEqual value: 'this', scopes: ['source.java', 'variable.language']
    expect(tokens[6]).toEqual value: 'super', scopes: ['source.java', 'variable.language']

  fit 'tokenizes literals', ->
    tokens = tokenizeLines '''
      a = null;
      a = true;
      a = false;
      a = 123;
      a = 0x1a;
      a = 0b11010;
      a = 123L;
      a = 123l;
      a = 123.4;
      a = 123.4d;
      a = 1.234e2;
      a = 123.4f;
      a = 'a';
      a = '\u0108'
      a = "abc";
    '''

    expect(tokens[0][3]).toEqual value: 'null', scopes: ['source.java', 'constant.language.null']
    expect(tokens[1][3]).toEqual value: 'true', scopes: ['source.java', 'constant.boolean']
    expect(tokens[2][3]).toEqual value: 'false', scopes: ['source.java', 'constant.boolean']
    expect(tokens[3][3]).toEqual value: '123', scopes: ['source.java', 'constant.numeric']
    expect(tokens[4][3]).toEqual value: '0x1a', scopes: ['source.java', 'constant.numeric']
    expect(tokens[5][3]).toEqual value: '0b11010', scopes: ['source.java', 'constant.numeric']
    expect(tokens[6][3]).toEqual value: '123L', scopes: ['source.java', 'constant.numeric']
    expect(tokens[7][3]).toEqual value: '123l', scopes: ['source.java', 'constant.numeric']
    expect(tokens[8][3]).toEqual value: '123.4', scopes: ['source.java', 'constant.numeric']
    expect(tokens[9][3]).toEqual value: '123.4d', scopes: ['source.java', 'constant.numeric']
    expect(tokens[10][3]).toEqual value: '1.234e2', scopes: ['source.java', 'constant.numeric']
    expect(tokens[11][3]).toEqual value: '123.4f', scopes: ['source.java', 'constant.numeric']
    expect(tokens[12][3]).toEqual value: '\'a\'', scopes: ['source.java', 'string.quoted.single']
    expect(tokens[13][3]).toEqual value: '\'\u0108\'', scopes: ['source.java', 'string.quoted.single']
    expect(tokens[14][3]).toEqual value: '\"abc\"', scopes: ['source.java', 'string.quoted.double']

  fit 'tokenizes comments', ->
    tokens = tokenizeLines '''
      // comment

      /*
       comment
       */
    '''

    expect(tokens[0][0]).toEqual value: '// comment', scopes: ['source.java', 'comment.block']
    expect(tokens[2][0]).toEqual value: '/*', scopes: ['source.java', 'comment.block']
    expect(tokens[3][0]).toEqual value: ' comment', scopes: ['source.java', 'comment.block']
    expect(tokens[4][0]).toEqual value: ' */', scopes: ['source.java', 'comment.block']

  fit 'tokenizes type definitions', ->
    tokens = tokenizeLines '''
      class A {
        void method() { }
        boolean method() { }
        int method() { }
        long method() { }
        float method() { }
        double method() { }
        int[] method() { }
        T method() { }
        java.util.List<T> method() { }
      }
    '''

    expect(tokens[1][1]).toEqual value: 'void', scopes: ['source.java', 'meta.class.body', 'meta.method', 'storage.type']
    expect(tokens[2][1]).toEqual value: 'boolean', scopes: ['source.java', 'meta.class.body', 'meta.method', 'storage.type']
    expect(tokens[3][1]).toEqual value: 'int', scopes: ['source.java', 'meta.class.body', 'meta.method', 'storage.type']
    expect(tokens[4][1]).toEqual value: 'long', scopes: ['source.java', 'meta.class.body', 'meta.method', 'storage.type']
    expect(tokens[5][1]).toEqual value: 'float', scopes: ['source.java', 'meta.class.body', 'meta.method', 'storage.type']
    expect(tokens[6][1]).toEqual value: 'double', scopes: ['source.java', 'meta.class.body', 'meta.method', 'storage.type']
    expect(tokens[7][1]).toEqual value: 'int', scopes: ['source.java', 'meta.class.body', 'meta.method', 'storage.type']
    expect(tokens[8][1]).toEqual value: 'T', scopes: ['source.java', 'meta.class.body', 'meta.method', 'storage.type']
    expect(tokens[9][1]).toEqual value: 'java', scopes: ['source.java', 'meta.class.body', 'meta.method', 'storage.type']
    expect(tokens[9][3]).toEqual value: 'util', scopes: ['source.java', 'meta.class.body', 'meta.method', 'storage.type']
    expect(tokens[9][5]).toEqual value: 'List', scopes: ['source.java', 'meta.class.body', 'meta.method', 'storage.type']
    expect(tokens[9][7]).toEqual value: 'T', scopes: ['source.java', 'meta.class.body', 'meta.method', 'storage.type']

  fit 'tokenizes generic type definitions', ->
    tokens = tokenizeLines '''
      class A {
        void method() { }
        boolean method() { }
        int method() { }
        long method() { }
        float method() { }
        double method() { }
        T method() { }
        java.util.List<T> method() { }
      }
    '''

  # fit 'tokenizes annotations', ->
  #   tokens = tokenizeLines '''
  #     @Annotation1
  #     @Annotation2()
  #     @Annotation3("value")
  #     @Annotation4(key = "value")
  #     class A { }
  #   '''
  #
  #   expect(tokens[0][0]).toEqual value: '@', scopes: ['source.java', 'storage.modifier', 'punctuation.definition.annotation']
  #   expect(tokens[0][1]).toEqual value: 'Annotation1', scopes: ['source.java', 'storage.modifier', 'storage.type.annotation']
  #   expect(tokens[1][0]).toEqual value: '@', scopes: ['source.java', 'storage.modifier', 'punctuation.definition.annotation']
  #   expect(tokens[1][1]).toEqual value: 'Annotation2', scopes: ['source.java', 'storage.modifier', 'storage.type.annotation']
  #   expect(tokens[2][0]).toEqual value: '@', scopes: ['source.java', 'storage.modifier', 'punctuation.definition.annotation']
  #   expect(tokens[2][1]).toEqual value: 'Annotation3', scopes: ['source.java', 'storage.modifier', 'storage.type.annotation']
  #   expect(tokens[2][3]).toEqual value: '\"value\"', scopes: ['source.java', 'storage.modifier', 'string.quoted.double']
  #   expect(tokens[3][0]).toEqual value: '@', scopes: ['source.java', 'storage.modifier', 'punctuation.definition.annotation']
  #   expect(tokens[3][1]).toEqual value: 'Annotation4', scopes: ['source.java', 'storage.modifier', 'storage.type.annotation']
  #   expect(tokens[3][3]).toEqual value: 'key', scopes: ['source.java', 'storage.modifier', 'variable.other.annotation.element']
  #   expect(tokens[3][7]).toEqual value: '\"value\"', scopes: ['source.java', 'storage.modifier', 'string.quoted.double']
  #
  # fit 'tokenizes ternary', ->
  #   tokens = tokenizeLine '(a > b) ? a : b;'
  #
  #   expect(tokens[6]).toEqual value: '?', scopes: ['source.java', 'keyword.control.ternary']
  #   expect(tokens[8]).toEqual value: ':', scopes: ['source.java', 'keyword.control.ternary']
  #
  # fit 'tokenizes imports', ->
  #   tokens = tokenizeLine 'import com.package;'
  #
  #   expect(tokens[0]).toEqual value: 'import', scopes: ['source.java', 'meta.import', 'keyword.other.import']
  #   expect(tokens[2]).toEqual value: 'com', scopes: ['source.java', 'meta.import', 'storage.type']
  #   expect(tokens[3]).toEqual value: '.', scopes: ['source.java', 'meta.import', 'punctuation.separator.period']
  #   expect(tokens[4]).toEqual value: 'package', scopes: ['source.java', 'meta.import', 'storage.type']
  #   expect(tokens[5]).toEqual value: ';', scopes: ['source.java', 'meta.import', 'punctuation.terminator.statement']
  #
  # fit 'tokenizes static imports', ->
  #   tokens = tokenizeLine 'import static com.package;'
  #
  #   expect(tokens[0]).toEqual value: 'import', scopes: ['source.java', 'meta.import', 'keyword.other.import']
  #   expect(tokens[2]).toEqual value: 'static', scopes: ['source.java', 'meta.import', 'storage.modifier']
  #   expect(tokens[4]).toEqual value: 'com', scopes: ['source.java', 'meta.import', 'storage.type']
  #   expect(tokens[5]).toEqual value: '.', scopes: ['source.java', 'meta.import', 'punctuation.separator.period']
  #   expect(tokens[6]).toEqual value: 'package', scopes: ['source.java', 'meta.import', 'storage.type']
  #   expect(tokens[7]).toEqual value: ';', scopes: ['source.java', 'meta.import', 'punctuation.terminator.statement']
  #
  # fit 'tokenizes imports with asterisk', ->
  #   tokens = tokenizeLine 'import static com.package.*;'
  #
  #   expect(tokens[0]).toEqual value: 'import', scopes: ['source.java', 'meta.import', 'keyword.other.import']
  #   expect(tokens[2]).toEqual value: 'static', scopes: ['source.java', 'meta.import', 'storage.modifier']
  #   expect(tokens[4]).toEqual value: 'com', scopes: ['source.java', 'meta.import', 'storage.type']
  #   expect(tokens[5]).toEqual value: '.', scopes: ['source.java', 'meta.import', 'punctuation.separator.period']
  #   expect(tokens[6]).toEqual value: 'package', scopes: ['source.java', 'meta.import', 'storage.type']
  #   expect(tokens[7]).toEqual value: '.', scopes: ['source.java', 'meta.import', 'punctuation.separator.period']
  #   expect(tokens[8]).toEqual value: '*', scopes: ['source.java', 'meta.import', 'storage.type']
  #   expect(tokens[9]).toEqual value: ';', scopes: ['source.java', 'meta.import', 'punctuation.terminator.statement']
  #
  # fit 'tokenizes field access', ->
  #   tokens = tokenizeLines '''
  #     a = b.c.d;
  #     a = this.c.d;
  #     a = super.c.d;
  #   '''
  #
  #   expect(tokens[0][3]).toEqual value: 'b', scopes: ['source.java', 'variable.other.object.java']
  #   expect(tokens[0][5]).toEqual value: 'c', scopes: ['source.java', 'variable.other.object.java']
  #   expect(tokens[0][7]).toEqual value: 'd', scopes: ['source.java', 'variable.other.object.java']
  #   expect(tokens[1][3]).toEqual value: 'this', scopes: ['source.java', 'variable.language']
  #   expect(tokens[1][5]).toEqual value: 'c', scopes: ['source.java', 'variable.other.object.java']
  #   expect(tokens[1][7]).toEqual value: 'd', scopes: ['source.java', 'variable.other.object.java']
  #   expect(tokens[2][3]).toEqual value: 'super', scopes: ['source.java', 'variable.language']
  #   expect(tokens[2][5]).toEqual value: 'c', scopes: ['source.java', 'variable.other.object.java']
  #   expect(tokens[2][7]).toEqual value: 'd', scopes: ['source.java', 'variable.other.object.java']
  #
  # fit 'tokenizes method invocations', ->
  #   tokens = tokenizeLines '''
  #     a = method();
  #     a = this.method();
  #     a = super.method();
  #     a = b.method();
  #     a = b.c.method();
  #   '''
  #
  #   expect(tokens[0][3]).toEqual value: 'method', scopes: ['source.java', 'entity.name.function']
  #   expect(tokens[1][5]).toEqual value: 'method', scopes: ['source.java', 'entity.name.function']
  #   expect(tokens[2][5]).toEqual value: 'method', scopes: ['source.java', 'entity.name.function']
  #   expect(tokens[3][5]).toEqual value: 'method', scopes: ['source.java', 'entity.name.function']
  #   expect(tokens[4][7]).toEqual value: 'method', scopes: ['source.java', 'entity.name.function']
  #
  # fit 'tokenizes interfaces', ->
  #   tokens = tokenizeLine 'public interface A { }'
  #
  #   expect(tokens[0]).toEqual value: 'public', scopes: ['source.java', 'storage.modifier']
  #   expect(tokens[2]).toEqual value: 'interface', scopes: ['source.java', 'keyword.other.interface']
  #   expect(tokens[4]).toEqual value: 'A', scopes: ['source.java', 'entity.name.type.interface']
  #   expect(tokens[6]).toEqual value: '{', scopes: ['source.java', 'meta.interface.body', 'punctuation.bracket.curly']
  #   expect(tokens[8]).toEqual value: '}', scopes: ['source.java', 'meta.interface.body', 'punctuation.bracket.curly']
  #
  # fit 'tokenizes annotated interfaces', ->
  #   tokens = tokenizeLines '''
  #     public @interface A {
  #       String method() default "abc";
  #     }
  #   '''
  #
  #   expect(tokens[0][0]).toEqual value: 'public', scopes: ['source.java', 'storage.modifier']
  #   expect(tokens[0][2]).toEqual value: '@', scopes: ['source.java', 'keyword.other.interface.annotated']
  #   expect(tokens[0][3]).toEqual value: 'interface', scopes: ['source.java', 'keyword.other.interface.annotated']
  #   expect(tokens[0][5]).toEqual value: 'A', scopes: ['source.java', 'entity.name.type.interface.annotated']
  #   expect(tokens[0][7]).toEqual value: '{', scopes: ['source.java', 'meta.interface.annotated.body', 'punctuation.bracket.curly']
  #   expect(tokens[1][1]).toEqual value: 'String', scopes: ['source.java', 'meta.interface.annotated.body', 'storage.type']
  #   expect(tokens[1][3]).toEqual value: 'method', scopes: ['source.java', 'meta.interface.annotated.body', 'entity.name.function']
  #   expect(tokens[1][7]).toEqual value: 'default', scopes: ['source.java', 'meta.interface.annotated.body', 'keyword.control']
  #   expect(tokens[1][9]).toEqual value: '\"abc\"', scopes: ['source.java', 'meta.interface.annotated.body', 'string.quoted.double']
  #   expect(tokens[2][0]).toEqual value: '}', scopes: ['source.java', 'meta.interface.annotated.body', 'punctuation.bracket.curly']
  #
  # fit 'tokenizes classes', ->
  #   tokens = tokenizeLine 'public abstract class A { }'
  #
  #   expect(tokens[0]).toEqual value: 'public', scopes: ['source.java', 'storage.modifier']
  #   expect(tokens[2]).toEqual value: 'abstract', scopes: ['source.java', 'storage.modifier']
  #   expect(tokens[4]).toEqual value: 'class', scopes: ['source.java', 'keyword.other.class']
  #   expect(tokens[6]).toEqual value: 'A', scopes: ['source.java', 'entity.name.type.class']
  #   expect(tokens[8]).toEqual value: '{', scopes: ['source.java', 'meta.class.body', 'punctuation.bracket.curly']
  #   expect(tokens[10]).toEqual value: '}', scopes: ['source.java', 'meta.class.body', 'punctuation.bracket.curly']
  #
  #   tokens = tokenizeLine 'class A extends B implements C, D { }'
  #
  #   expect(tokens[0]).toEqual value: 'class', scopes: ['source.java', 'keyword.other.class']
  #   expect(tokens[2]).toEqual value: 'A', scopes: ['source.java', 'entity.name.type.class']
  #   expect(tokens[4]).toEqual value: 'extends', scopes: ['source.java', 'storage.modifier']
  #   expect(tokens[6]).toEqual value: 'B', scopes: ['source.java', 'storage.type']
  #   expect(tokens[8]).toEqual value: 'implements', scopes: ['source.java', 'storage.modifier']
  #   expect(tokens[10]).toEqual value: 'C', scopes: ['source.java', 'storage.type']
  #   expect(tokens[13]).toEqual value: 'D', scopes: ['source.java', 'storage.type']
  #
  # fit 'tokenizes enums', ->
  #   tokens = tokenizeLines '''
  #     public enum A implements B {
  #       C1,
  #       C2
  #     }
  #   '''
  #
  #   expect(tokens[0][0]).toEqual value: 'public', scopes: ['source.java', 'storage.modifier']
  #   expect(tokens[0][2]).toEqual value: 'enum', scopes: ['source.java', 'keyword.other.enum']
  #   expect(tokens[0][4]).toEqual value: 'A', scopes: ['source.java', 'entity.name.type.enum']
  #   expect(tokens[0][6]).toEqual value: 'implements', scopes: ['source.java', 'storage.modifier']
  #   expect(tokens[0][8]).toEqual value: 'B', scopes: ['source.java', 'storage.type']
  #   expect(tokens[0][10]).toEqual value: '{', scopes: ['source.java', 'punctuation.bracket.curly']
  #   expect(tokens[1][1]).toEqual value: 'C1', scopes: ['source.java', 'constant.other.enum']
  #   expect(tokens[2][1]).toEqual value: 'C2', scopes: ['source.java', 'constant.other.enum']
  #   expect(tokens[3][0]).toEqual value: '}', scopes: ['source.java', 'punctuation.bracket.curly']
  #
  # fit 'tokenizes static initializers', ->
  #   tokens = tokenizeLines '''
  #     class A {
  #       private static int a = 0;
  #
  #       static {
  #         a = 1;
  #       }
  #     }
  #   '''
  #
  #   expect(tokens[1][3]).toEqual value: 'static', scopes: ['source.java', 'meta.class.body', 'storage.modifier']
  #   expect(tokens[3][1]).toEqual value: 'static', scopes: ['source.java', 'meta.class.body', 'storage.modifier']
  #
  # fit 'tokenizes method declarations', ->
  #   tokens = tokenizeLines '''
  #     class A {
  #       public A() {
  #         super();
  #       }
  #
  #       public int method() {
  #         return 1;
  #       }
  #     }
  #   '''
  #
  #   expect(tokens[1][1]).toEqual value: 'public', scopes: ['source.java', 'meta.class.body', 'meta.constructor', 'storage.modifier']
  #   expect(tokens[1][3]).toEqual value: 'A', scopes: ['source.java', 'meta.class.body', 'meta.constructor', 'entity.name.function']
  #   expect(tokens[2][1]).toEqual value: 'super', scopes: ['source.java', 'meta.class.body', 'meta.constructor', 'meta.constructor.body', 'variable.language']
  #   expect(tokens[5][1]).toEqual value: 'public', scopes: ['source.java', 'meta.class.body', 'meta.method', 'storage.modifier']
  #   expect(tokens[5][3]).toEqual value: 'int', scopes: ['source.java', 'meta.class.body', 'meta.method', 'storage.type']
  #   expect(tokens[5][5]).toEqual value: 'method', scopes: ['source.java', 'meta.class.body', 'meta.method', 'entity.name.function']
  #   expect(tokens[6][1]).toEqual value: 'return', scopes: ['source.java', 'meta.class.body', 'meta.method', 'meta.method.body', 'keyword.control']
  #   expect(tokens[6][3]).toEqual value: '1', scopes: ['source.java', 'meta.class.body', 'meta.method', 'meta.method.body', 'constant.numeric']
