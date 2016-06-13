describe 'Java grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-java')

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.java')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.java'

  it 'tokenizes this with `.this` class', ->
    {tokens} = grammar.tokenizeLine 'this.x'

    expect(tokens[0]).toEqual value: 'this', scopes: ['source.java', 'variable.language.this.java']

  it 'tokenizes braces', ->
    {tokens} = grammar.tokenizeLine '(3 + 5) + a[b]'

    expect(tokens[0]).toEqual value: '(', scopes: ['source.java', 'punctuation.bracket.round.java']
    expect(tokens[6]).toEqual value: ')', scopes: ['source.java', 'punctuation.bracket.round.java']
    expect(tokens[10]).toEqual value: '[', scopes: ['source.java', 'punctuation.bracket.square.java']
    expect(tokens[12]).toEqual value: ']', scopes: ['source.java', 'punctuation.bracket.square.java']

    {tokens} = grammar.tokenizeLine 'a(b)'

    expect(tokens[1]).toEqual value: '(', scopes: ['source.java', 'meta.function-call.java', 'punctuation.definition.parameters.begin.bracket.round.java']
    expect(tokens[3]).toEqual value: ')', scopes: ['source.java', 'meta.function-call.java', 'punctuation.definition.parameters.end.bracket.round.java']

    lines = grammar.tokenizeLines '''
      class A<String>
      {
        public int[][] something(String[][] hello)
        {
        }
      }
    '''

    expect(lines[0][3]).toEqual value: '<', scopes: ['source.java', 'meta.class.java', 'punctuation.bracket.angle.java']
    expect(lines[0][5]).toEqual value: '>', scopes: ['source.java', 'meta.class.java', 'punctuation.bracket.angle.java']
    expect(lines[1][0]).toEqual value: '{', scopes: ['source.java', 'meta.class.java', 'punctuation.section.class.begin.bracket.curly.java']
    expect(lines[2][4]).toEqual value: '[', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.return-type.java', 'storage.type.primitive.array.java', 'punctuation.bracket.square.java']
    expect(lines[2][5]).toEqual value: ']', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.return-type.java', 'storage.type.primitive.array.java', 'punctuation.bracket.square.java']
    expect(lines[2][6]).toEqual value: '[', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.return-type.java', 'storage.type.primitive.array.java', 'punctuation.bracket.square.java']
    expect(lines[2][7]).toEqual value: ']', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.return-type.java', 'storage.type.primitive.array.java', 'punctuation.bracket.square.java']
    expect(lines[2][8]).toEqual value: ' ', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java']
    expect(lines[2][10]).toEqual value: '(', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'punctuation.definition.parameters.begin.bracket.round.java']
    expect(lines[2][12]).toEqual value: '[', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'storage.type.object.array.java', 'punctuation.bracket.square.java']
    expect(lines[2][13]).toEqual value: ']', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'storage.type.object.array.java', 'punctuation.bracket.square.java']
    expect(lines[2][14]).toEqual value: '[', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'storage.type.object.array.java', 'punctuation.bracket.square.java']
    expect(lines[2][15]).toEqual value: ']', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'storage.type.object.array.java', 'punctuation.bracket.square.java']
    expect(lines[2][18]).toEqual value: ')', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'punctuation.definition.parameters.end.bracket.round.java']
    expect(lines[3][1]).toEqual value: '{', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'punctuation.section.method.begin.bracket.curly.java']
    expect(lines[4][1]).toEqual value: '}', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'punctuation.section.method.end.bracket.curly.java']
    expect(lines[5][0]).toEqual value: '}', scopes: ['source.java', 'meta.class.java', 'punctuation.section.class.end.bracket.curly.java']

  it 'tokenizes punctuation', ->
    {tokens} = grammar.tokenizeLine 'int a, b, c;'

    expect(tokens[2]).toEqual value: ',', scopes: ['source.java', 'punctuation.separator.delimiter.java']
    expect(tokens[4]).toEqual value: ',', scopes: ['source.java', 'punctuation.separator.delimiter.java']
    expect(tokens[6]).toEqual value: ';', scopes: ['source.java', 'punctuation.terminator.java']

    {tokens} = grammar.tokenizeLine 'a.b(1, 2, c);'

    expect(tokens[1]).toEqual value: '.', scopes: ['source.java', 'meta.method-call.java', 'punctuation.separator.period.java']
    expect(tokens[5]).toEqual value: ',', scopes: ['source.java', 'meta.method-call.java', 'punctuation.separator.delimiter.java']
    expect(tokens[8]).toEqual value: ',', scopes: ['source.java', 'meta.method-call.java', 'punctuation.separator.delimiter.java']
    expect(tokens[11]).toEqual value: ';', scopes: ['source.java', 'punctuation.terminator.java']

    {tokens} = grammar.tokenizeLine 'a . b'

    expect(tokens[2]).toEqual value: '.', scopes: ['source.java', 'punctuation.separator.period.java']

    {tokens} = grammar.tokenizeLine 'class A implements B, C'

    expect(tokens[7]).toEqual value: ',', scopes: ['source.java', 'meta.class.java', 'meta.definition.class.implemented.interfaces.java', 'punctuation.separator.delimiter.java']

  it 'tokenizes the `package` keyword', ->
    {tokens} = grammar.tokenizeLine 'package java.util.example;'

    expect(tokens[0]).toEqual value: 'package', scopes: ['source.java', 'meta.package.java', 'keyword.other.package.java']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.java', 'meta.package.java']
    expect(tokens[2]).toEqual value: 'java', scopes: ['source.java', 'meta.package.java', 'storage.modifier.package.java']
    expect(tokens[3]).toEqual value: '.', scopes: ['source.java', 'meta.package.java', 'storage.modifier.package.java', 'punctuation.separator.java']
    expect(tokens[4]).toEqual value: 'util', scopes: ['source.java', 'meta.package.java', 'storage.modifier.package.java']
    expect(tokens[7]).toEqual value: ';', scopes: ['source.java', 'meta.package.java', 'punctuation.terminator.java']

    {tokens} = grammar.tokenizeLine 'package java.Hi;'

    expect(tokens[4]).toEqual value: 'H', scopes: ['source.java', 'meta.package.java', 'storage.modifier.package.java', 'invalid.illegal.character_not_allowed_here.java']

    {tokens} = grammar.tokenizeLine 'package java.3a;'

    expect(tokens[4]).toEqual value: '3', scopes: ['source.java', 'meta.package.java', 'storage.modifier.package.java', 'invalid.illegal.character_not_allowed_here.java']

    {tokens} = grammar.tokenizeLine 'package java.-hi;'

    expect(tokens[4]).toEqual value: '-', scopes: ['source.java', 'meta.package.java', 'storage.modifier.package.java', 'invalid.illegal.character_not_allowed_here.java']

    {tokens} = grammar.tokenizeLine 'package java._;'

    expect(tokens[4]).toEqual value: '_', scopes: ['source.java', 'meta.package.java', 'storage.modifier.package.java', 'invalid.illegal.character_not_allowed_here.java']

    {tokens} = grammar.tokenizeLine 'package java.__;'

    expect(tokens[4]).toEqual value: '__', scopes: ['source.java', 'meta.package.java', 'storage.modifier.package.java']

    {tokens} = grammar.tokenizeLine 'package java.int;'

    expect(tokens[4]).toEqual value: 'int', scopes: ['source.java', 'meta.package.java', 'storage.modifier.package.java', 'invalid.illegal.character_not_allowed_here.java']

    {tokens} = grammar.tokenizeLine 'package java.interesting;'

    expect(tokens[4]).toEqual value: 'interesting', scopes: ['source.java', 'meta.package.java', 'storage.modifier.package.java']

    {tokens} = grammar.tokenizeLine 'package java..hi;'

    expect(tokens[4]).toEqual value: '.', scopes: ['source.java', 'meta.package.java', 'storage.modifier.package.java', 'invalid.illegal.character_not_allowed_here.java']

    {tokens} = grammar.tokenizeLine 'package java.;'

    expect(tokens[3]).toEqual value: '.', scopes: ['source.java', 'meta.package.java', 'storage.modifier.package.java', 'invalid.illegal.character_not_allowed_here.java']

  it 'tokenizes the `import` keyword', ->
    {tokens} = grammar.tokenizeLine 'import java.util.Example;'

    expect(tokens[0]).toEqual value: 'import', scopes: ['source.java', 'meta.import.java', 'keyword.other.import.java']
    expect(tokens[1]).toEqual value: ' ', scopes: ['source.java', 'meta.import.java']
    expect(tokens[2]).toEqual value: 'java', scopes: ['source.java', 'meta.import.java', 'storage.modifier.import.java']
    expect(tokens[3]).toEqual value: '.', scopes: ['source.java', 'meta.import.java', 'storage.modifier.import.java', 'punctuation.separator.java']
    expect(tokens[4]).toEqual value: 'util', scopes: ['source.java', 'meta.import.java', 'storage.modifier.import.java']
    expect(tokens[7]).toEqual value: ';', scopes: ['source.java', 'meta.import.java', 'punctuation.terminator.java']

    {tokens} = grammar.tokenizeLine 'import java.util.*;'

    expect(tokens[6]).toEqual value: '*', scopes: ['source.java', 'meta.import.java', 'storage.modifier.import.java', 'variable.language.wildcard.java']

    {tokens} = grammar.tokenizeLine 'import static java.lang.Math.PI;'

    expect(tokens[2]).toEqual value: 'static', scopes: ['source.java', 'meta.import.java', 'storage.modifier.java']

    {tokens} = grammar.tokenizeLine 'import java.3a;'

    expect(tokens[4]).toEqual value: '3', scopes: ['source.java', 'meta.import.java', 'storage.modifier.import.java', 'invalid.illegal.character_not_allowed_here.java']

    {tokens} = grammar.tokenizeLine 'import java.-hi;'

    expect(tokens[4]).toEqual value: '-', scopes: ['source.java', 'meta.import.java', 'storage.modifier.import.java', 'invalid.illegal.character_not_allowed_here.java']

    {tokens} = grammar.tokenizeLine 'import java._;'

    expect(tokens[4]).toEqual value: '_', scopes: ['source.java', 'meta.import.java', 'storage.modifier.import.java', 'invalid.illegal.character_not_allowed_here.java']

    {tokens} = grammar.tokenizeLine 'import java.__;'

    expect(tokens[4]).toEqual value: '__', scopes: ['source.java', 'meta.import.java', 'storage.modifier.import.java']

    {tokens} = grammar.tokenizeLine 'import java.**;'

    expect(tokens[5]).toEqual value: '*', scopes: ['source.java', 'meta.import.java', 'storage.modifier.import.java', 'invalid.illegal.character_not_allowed_here.java']

    {tokens} = grammar.tokenizeLine 'import java.a*;'

    expect(tokens[5]).toEqual value: '*', scopes: ['source.java', 'meta.import.java', 'storage.modifier.import.java', 'invalid.illegal.character_not_allowed_here.java']

    {tokens} = grammar.tokenizeLine 'import java.int;'

    expect(tokens[4]).toEqual value: 'int', scopes: ['source.java', 'meta.import.java', 'storage.modifier.import.java', 'invalid.illegal.character_not_allowed_here.java']

    {tokens} = grammar.tokenizeLine 'import java.interesting;'

    expect(tokens[4]).toEqual value: 'interesting', scopes: ['source.java', 'meta.import.java', 'storage.modifier.import.java']

    {tokens} = grammar.tokenizeLine 'import java..hi;'

    expect(tokens[4]).toEqual value: '.', scopes: ['source.java', 'meta.import.java', 'storage.modifier.import.java', 'invalid.illegal.character_not_allowed_here.java']

    {tokens} = grammar.tokenizeLine 'import java.;'

    expect(tokens[3]).toEqual value: '.', scopes: ['source.java', 'meta.import.java', 'storage.modifier.import.java', 'invalid.illegal.character_not_allowed_here.java']

  it 'tokenizes classes', ->
    lines = grammar.tokenizeLines '''
      class Thing {
        int x;
      }
    '''

    expect(lines[0][0]).toEqual value: 'class', scopes: ['source.java', 'meta.class.java', 'meta.class.identifier.java', 'storage.modifier.java']
    expect(lines[0][2]).toEqual value: 'Thing', scopes: ['source.java', 'meta.class.java', 'meta.class.identifier.java', 'entity.name.type.class.java']

  it 'tokenizes enums', ->
    lines = grammar.tokenizeLines '''
      enum Letters {
        /** Comment about A */
        A,

        // Comment about B
        B
      }
    '''

    comment = ['source.java', 'meta.enum.java', 'comment.block.java']
    commentDefinition = comment.concat('punctuation.definition.comment.java')

    expect(lines[0][0]).toEqual value: 'enum', scopes: ['source.java', 'meta.enum.java', 'storage.modifier.java']
    expect(lines[0][2]).toEqual value: 'Letters', scopes: ['source.java', 'meta.enum.java', 'entity.name.type.enum.java']
    expect(lines[0][4]).toEqual value: '{', scopes: ['source.java', 'meta.enum.java', 'punctuation.section.enum.begin.bracket.curly.java']
    expect(lines[1][1]).toEqual value: '/*', scopes: commentDefinition
    expect(lines[1][2]).toEqual value: '* Comment about A ', scopes: comment
    expect(lines[1][3]).toEqual value: '*/', scopes: commentDefinition
    expect(lines[2][1]).toEqual value: 'A', scopes: ['source.java', 'meta.enum.java', 'constant.other.enum.java']
    expect(lines[6][0]).toEqual value: '}', scopes: ['source.java', 'meta.enum.java', 'punctuation.section.enum.end.bracket.curly.java']

  it 'tokenizes methods', ->
    lines = grammar.tokenizeLines '''
      class A
      {
        A(int a, int b)
        {
        }
      }
    '''

    expect(lines[2][1]).toEqual value: 'A', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'entity.name.function.java']
    expect(lines[2][2]).toEqual value: '(', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'punctuation.definition.parameters.begin.bracket.round.java']
    expect(lines[2][3]).toEqual value: 'int', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'storage.type.primitive.java']
    expect(lines[2][5]).toEqual value: 'a', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'variable.parameter.java']
    expect(lines[2][6]).toEqual value: ',', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'punctuation.separator.delimiter.java']
    expect(lines[2][11]).toEqual value: ')', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'punctuation.definition.parameters.end.bracket.round.java']
    expect(lines[3][1]).toEqual value: '{', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'punctuation.section.method.begin.bracket.curly.java']
    expect(lines[4][1]).toEqual value: '}', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'punctuation.section.method.end.bracket.curly.java']

  it 'tokenizes method-local variables', ->
    lines = grammar.tokenizeLines '''
      class A
      {
        public void fn()
        {
          String someString;
          String assigned = "Rand al'Thor";
          int primitive = 5;
        }
      }
    '''

    expect(lines[4][1]).toEqual value: 'String', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.definition.variable.java', 'storage.type.java']
    expect(lines[4][3]).toEqual value: 'someString', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.definition.variable.java', 'variable.definition.java']

    expect(lines[5][1]).toEqual value: 'String', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.definition.variable.java', 'storage.type.java']
    expect(lines[5][3]).toEqual value: 'assigned', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.definition.variable.java', 'variable.definition.java']
    expect(lines[5][8]).toEqual value: "Rand al'Thor", scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.definition.variable.java', 'string.quoted.double.java']

    expect(lines[6][1]).toEqual value: 'int', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.definition.variable.java', 'storage.type.primitive.java']
    expect(lines[6][3]).toEqual value: 'primitive', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.definition.variable.java', 'variable.definition.java']
    expect(lines[6][7]).toEqual value: '5', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.definition.variable.java', 'constant.numeric.java']

  it 'tokenizes function and method calls', ->
    lines = grammar.tokenizeLines '''
      class A
      {
        A()
        {
          hello();
          hello(a, b);
          $hello();
          this.hello();
          this . hello(a, b);
        }
      }
    '''

    expect(lines[4][1]).toEqual value: 'hello', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.function-call.java', 'entity.name.function.java']
    expect(lines[4][2]).toEqual value: '(', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.function-call.java', 'punctuation.definition.parameters.begin.bracket.round.java']
    expect(lines[4][3]).toEqual value: ')', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.function-call.java', 'punctuation.definition.parameters.end.bracket.round.java']
    expect(lines[4][4]).toEqual value: ';', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'punctuation.terminator.java']

    expect(lines[5][1]).toEqual value: 'hello', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.function-call.java', 'entity.name.function.java']
    expect(lines[5][3]).toEqual value: 'a', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.function-call.java']
    expect(lines[5][4]).toEqual value: ',', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.function-call.java', 'punctuation.separator.delimiter.java']
    expect(lines[5][7]).toEqual value: ';', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'punctuation.terminator.java']

    expect(lines[6][1]).toEqual value: '$hello', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.function-call.java', 'entity.name.function.java']

    expect(lines[7][1]).toEqual value: 'this', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.language.this.java']
    expect(lines[7][2]).toEqual value: '.', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.method-call.java', 'punctuation.separator.period.java']
    expect(lines[7][3]).toEqual value: 'hello', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.method-call.java', 'entity.name.function.java']
    expect(lines[7][4]).toEqual value: '(', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.method-call.java', 'punctuation.definition.parameters.begin.bracket.round.java']
    expect(lines[7][5]).toEqual value: ')', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.method-call.java', 'punctuation.definition.parameters.end.bracket.round.java']
    expect(lines[7][6]).toEqual value: ';', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'punctuation.terminator.java']

    expect(lines[8][3]).toEqual value: '.', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.method-call.java', 'punctuation.separator.period.java']
    expect(lines[8][4]).toEqual value: ' ', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.method-call.java']
    expect(lines[8][5]).toEqual value: 'hello', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.method-call.java', 'entity.name.function.java']
    expect(lines[8][7]).toEqual value: 'a', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.method-call.java']
    expect(lines[8][8]).toEqual value: ',', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.method-call.java', 'punctuation.separator.delimiter.java']
    expect(lines[8][11]).toEqual value: ';', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'punctuation.terminator.java']

  it 'tokenizes objects and properties', ->
    lines = grammar.tokenizeLines '''
      class A
      {
        A()
        {
          object.property;
          object.Property;
          Object.property;
          object . property;
          $object.$property;
          object.property1.property2;
          object.method().property;
          object.property.method();
          object.123illegal;
        }
      }
    '''

    expect(lines[4][1]).toEqual value: 'object', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.other.object.java']
    expect(lines[4][2]).toEqual value: '.', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'punctuation.separator.period.java']
    expect(lines[4][3]).toEqual value: 'property', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.other.property.java']
    expect(lines[4][4]).toEqual value: ';', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'punctuation.terminator.java']

    expect(lines[5][1]).toEqual value: 'object', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.other.object.java']
    expect(lines[5][3]).toEqual value: 'Property', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.other.property.java']

    expect(lines[6][1]).toEqual value: 'Object', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.other.object.java']

    expect(lines[7][1]).toEqual value: 'object', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.other.object.java']
    expect(lines[7][5]).toEqual value: 'property', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.other.property.java']

    expect(lines[8][1]).toEqual value: '$object', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.other.object.java']
    expect(lines[8][3]).toEqual value: '$property', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.other.property.java']

    expect(lines[9][3]).toEqual value: 'property1', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.other.object.property.java']
    expect(lines[9][5]).toEqual value: 'property2', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.other.property.java']

    expect(lines[10][1]).toEqual value: 'object', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.other.object.java']
    expect(lines[10][3]).toEqual value: 'method', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.method-call.java', 'entity.name.function.java']
    expect(lines[10][7]).toEqual value: 'property', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.other.property.java']

    expect(lines[11][3]).toEqual value: 'property', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.other.object.property.java']
    expect(lines[11][5]).toEqual value: 'method', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'meta.method-call.java', 'entity.name.function.java']

    expect(lines[12][1]).toEqual value: 'object', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'variable.other.object.java']
    expect(lines[12][2]).toEqual value: '.', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'punctuation.separator.period.java']
    expect(lines[12][3]).toEqual value: '123illegal', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'invalid.illegal.identifier.java']
    expect(lines[12][4]).toEqual value: ';', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java', 'punctuation.terminator.java']

  it 'tokenizes generics', ->
    lines = grammar.tokenizeLines '''
      class A<T extends A & B, String, Integer>
      {
        HashMap<Integer, String> map = new HashMap<>();
        CodeMap<String, ? extends ArrayList> codemap;
        C(Map<?, ? extends List<?>> m) {}
        Map<Integer, String> method() {}
        private Object otherMethod() { return null; }
      }
    '''

    expect(lines[0][3]).toEqual value: '<', scopes: ['source.java', 'meta.class.java', 'punctuation.bracket.angle.java']
    expect(lines[0][4]).toEqual value: 'T', scopes: ['source.java', 'meta.class.java', 'storage.type.generic.java']
    expect(lines[0][5]).toEqual value: ' ', scopes: ['source.java', 'meta.class.java']
    expect(lines[0][6]).toEqual value: 'extends', scopes: ['source.java', 'meta.class.java', 'storage.modifier.extends.java']
    expect(lines[0][7]).toEqual value: ' ', scopes: ['source.java', 'meta.class.java']
    expect(lines[0][8]).toEqual value: 'A', scopes: ['source.java', 'meta.class.java', 'storage.type.generic.java']
    expect(lines[0][9]).toEqual value: ' ', scopes: ['source.java', 'meta.class.java']
    expect(lines[0][10]).toEqual value: '&', scopes: ['source.java', 'meta.class.java', 'punctuation.separator.types.java']
    expect(lines[0][11]).toEqual value: ' ', scopes: ['source.java', 'meta.class.java']
    expect(lines[0][12]).toEqual value: 'B', scopes: ['source.java', 'meta.class.java', 'storage.type.generic.java']
    expect(lines[0][13]).toEqual value: ',', scopes: ['source.java', 'meta.class.java', 'punctuation.separator.delimiter.java']
    expect(lines[0][14]).toEqual value: ' ', scopes: ['source.java', 'meta.class.java']
    expect(lines[0][15]).toEqual value: 'String', scopes: ['source.java', 'meta.class.java', 'storage.type.generic.java']
    expect(lines[0][16]).toEqual value: ',', scopes: ['source.java', 'meta.class.java', 'punctuation.separator.delimiter.java']
    expect(lines[0][17]).toEqual value: ' ', scopes: ['source.java', 'meta.class.java']
    expect(lines[0][18]).toEqual value: 'Integer', scopes: ['source.java', 'meta.class.java', 'storage.type.generic.java']
    expect(lines[0][19]).toEqual value: '>', scopes: ['source.java', 'meta.class.java', 'punctuation.bracket.angle.java']
    expect(lines[2][1]).toEqual value: 'HashMap', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'storage.type.java']
    expect(lines[2][2]).toEqual value: '<', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'punctuation.bracket.angle.java']
    expect(lines[2][3]).toEqual value: 'Integer', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'storage.type.generic.java']
    expect(lines[2][4]).toEqual value: ',', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'punctuation.separator.delimiter.java']
    expect(lines[2][6]).toEqual value: 'String', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'storage.type.generic.java']
    expect(lines[2][7]).toEqual value: '>', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'punctuation.bracket.angle.java']
    expect(lines[2][13]).toEqual value: 'HashMap', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'storage.type.java']
    expect(lines[2][14]).toEqual value: '<', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'punctuation.bracket.angle.java']
    expect(lines[2][15]).toEqual value: '>', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'punctuation.bracket.angle.java']
    expect(lines[3][1]).toEqual value: 'CodeMap', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'storage.type.java']
    expect(lines[3][2]).toEqual value: '<', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'punctuation.bracket.angle.java']
    expect(lines[3][3]).toEqual value: 'String', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'storage.type.generic.java']
    expect(lines[3][4]).toEqual value: ',', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'punctuation.separator.delimiter.java']
    expect(lines[3][6]).toEqual value: '?', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'storage.type.generic.wildcard.java']
    expect(lines[3][8]).toEqual value: 'extends', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'storage.modifier.extends.java']
    expect(lines[3][10]).toEqual value: 'ArrayList', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'storage.type.generic.java']
    expect(lines[3][11]).toEqual value: '>', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'punctuation.bracket.angle.java']
    expect(lines[3][12]).toEqual value: ' codemap', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java']
    expect(lines[4][1]).toEqual value: 'C', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'entity.name.function.java']
    expect(lines[4][3]).toEqual value: 'Map', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'storage.type.java']
    expect(lines[4][4]).toEqual value: '<', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'punctuation.bracket.angle.java']
    expect(lines[4][5]).toEqual value: '?', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'storage.type.generic.wildcard.java']
    expect(lines[4][6]).toEqual value: ',', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'punctuation.separator.delimiter.java']
    expect(lines[4][8]).toEqual value: '?', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'storage.type.generic.wildcard.java']
    expect(lines[4][10]).toEqual value: 'extends', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'storage.modifier.extends.java']
    expect(lines[4][12]).toEqual value: 'List', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'storage.type.java']
    expect(lines[4][13]).toEqual value: '<', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'punctuation.bracket.angle.java']
    expect(lines[4][14]).toEqual value: '?', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'storage.type.generic.wildcard.java']
    expect(lines[4][15]).toEqual value: '>', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'punctuation.bracket.angle.java']
    expect(lines[4][16]).toEqual value: '>', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'punctuation.bracket.angle.java']
    expect(lines[4][18]).toEqual value: 'm', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'variable.parameter.java']
    expect(lines[5][1]).toEqual value: 'Map', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.return-type.java', 'storage.type.java']
    expect(lines[5][2]).toEqual value: '<', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.return-type.java', 'punctuation.bracket.angle.java']
    expect(lines[5][3]).toEqual value: 'Integer', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.return-type.java', 'storage.type.generic.java']
    expect(lines[5][7]).toEqual value: '>', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.return-type.java', 'punctuation.bracket.angle.java']
    expect(lines[5][9]).toEqual value: 'method', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'entity.name.function.java']
    expect(lines[6][1]).toEqual value: 'private', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'storage.modifier.java']
    expect(lines[6][3]).toEqual value: 'Object', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.return-type.java', 'storage.type.java']
    expect(lines[6][5]).toEqual value: 'otherMethod', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.identifier.java', 'entity.name.function.java']

  it 'tokenizes lambda expressions', ->
    {tokens} = grammar.tokenizeLine '(String s1) -> s1.length() - outer.length();'

    expect(tokens[1]).toEqual value: 'String', scopes: ['source.java', 'storage.type.java']
    expect(tokens[5]).toEqual value: '->', scopes: ['source.java', 'storage.type.function.arrow.java']
    expect(tokens[8]).toEqual value: '.', scopes: ['source.java', 'meta.method-call.java', 'punctuation.separator.period.java']
    expect(tokens[10]).toEqual value: '(', scopes: ['source.java', 'meta.method-call.java', 'punctuation.definition.parameters.begin.bracket.round.java']
    expect(tokens[11]).toEqual value: ')', scopes: ['source.java', 'meta.method-call.java', 'punctuation.definition.parameters.end.bracket.round.java']
    expect(tokens[13]).toEqual value: '-', scopes: ['source.java', 'keyword.operator.arithmetic.java']

  it 'tokenizes the `instanceof` operator', ->
    {tokens} = grammar.tokenizeLine 'instanceof'

    expect(tokens[0]).toEqual value: 'instanceof', scopes: ['source.java', 'keyword.operator.instanceof.java']

  it 'tokenizes class fields', ->
    lines = grammar.tokenizeLines '''
      class Test
      {
        private int variable;
        public Object[] variable;
        private int variable = 3;
        private int variable1, variable2, variable3;
        private int variable1, variable2 = variable;
        private int variable;// = 3;
        public String CAPITALVARIABLE;
      }
      '''

    expect(lines[2][1]).toEqual value: 'private', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'storage.modifier.java']
    expect(lines[2][2]).toEqual value: ' ', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java']
    expect(lines[2][3]).toEqual value: 'int', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'storage.type.primitive.java']
    expect(lines[2][4]).toEqual value: ' ', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java']
    expect(lines[2][5]).toEqual value: 'variable', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'variable.definition.java']
    expect(lines[2][6]).toEqual value: ';', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'punctuation.terminator.java']

    expect(lines[3][1]).toEqual value: 'public', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'storage.modifier.java']
    expect(lines[3][3]).toEqual value: 'Object', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'storage.type.object.array.java']
    expect(lines[3][4]).toEqual value: '[', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'storage.type.object.array.java', 'punctuation.bracket.square.java']
    expect(lines[3][5]).toEqual value: ']', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'storage.type.object.array.java', 'punctuation.bracket.square.java']

    expect(lines[4][5]).toEqual value: 'variable', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'variable.definition.java']
    expect(lines[4][6]).toEqual value: ' ', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java']
    expect(lines[4][7]).toEqual value: '=', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'keyword.operator.assignment.java']
    expect(lines[4][8]).toEqual value: ' ', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java']
    expect(lines[4][9]).toEqual value: '3', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'constant.numeric.java']
    expect(lines[4][10]).toEqual value: ';', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'punctuation.terminator.java']

    expect(lines[5][5]).toEqual value: 'variable1', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'variable.definition.java']
    expect(lines[5][6]).toEqual value: ',', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'punctuation.separator.delimiter.java']
    expect(lines[5][7]).toEqual value: ' ', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java']
    expect(lines[5][8]).toEqual value: 'variable2', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'variable.definition.java']
    expect(lines[5][11]).toEqual value: 'variable3', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'variable.definition.java']
    expect(lines[5][12]).toEqual value: ';', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'punctuation.terminator.java']

    expect(lines[6][5]).toEqual value: 'variable1', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'variable.definition.java']
    expect(lines[6][8]).toEqual value: 'variable2', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'variable.definition.java']
    expect(lines[6][10]).toEqual value: '=', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'keyword.operator.assignment.java']
    expect(lines[6][11]).toEqual value: ' variable', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java']
    expect(lines[6][12]).toEqual value: ';', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'punctuation.terminator.java']

    expect(lines[7][5]).toEqual value: 'variable', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'variable.definition.java']
    expect(lines[7][6]).toEqual value: ';', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'punctuation.terminator.java']
    expect(lines[7][7]).toEqual value: '//', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'comment.line.double-slash.java', 'punctuation.definition.comment.java']

    expect(lines[8][5]).toEqual value: 'CAPITALVARIABLE', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'variable.definition.java']
    expect(lines[8][6]).toEqual value: ';', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'punctuation.terminator.java']

  it 'tokenizes try-catch-finally blocks', ->
    lines = grammar.tokenizeLines '''
    class Test {
      public void fn() {
        try {
          errorProneMethod();
        } catch (RuntimeException re) {
          handleRuntimeException(re);
        } catch (Exception e) {
          String variable = "assigning for some reason";
        } finally {
          // Relax, it's over
          new Thingie().call();
        }
      }
    }
    '''

    scopeStack = ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java']

    scopeStack.push 'meta.try.java'
    expect(lines[2][1]).toEqual value: 'try', scopes: scopeStack.concat ['keyword.control.try.java']
    expect(lines[2][3]).toEqual value: '{', scopes: scopeStack.concat ['punctuation.section.try.begin.bracket.curly.java']

    scopeStack.push 'meta.try.body.java'
    expect(lines[3][1]).toEqual value: 'errorProneMethod', scopes: scopeStack.concat ['meta.function-call.java', 'entity.name.function.java']

    scopeStack.pop()
    expect(lines[4][1]).toEqual value: '}', scopes: scopeStack.concat ['punctuation.section.try.end.bracket.curly.java']
    scopeStack.pop()
    scopeStack.push 'meta.catch.java'
    expect(lines[4][3]).toEqual value: 'catch', scopes: scopeStack.concat ['keyword.control.catch.java']
    expect(lines[4][5]).toEqual value: '(', scopes: scopeStack.concat ['punctuation.definition.parameters.begin.bracket.round.java']
    scopeStack.push 'meta.catch.parameters.java'
    expect(lines[4][6]).toEqual value: 'RuntimeException', scopes: scopeStack.concat ['storage.type.java']
    expect(lines[4][8]).toEqual value: 're', scopes: scopeStack.concat ['variable.parameter.java']
    scopeStack.pop()
    expect(lines[4][9]).toEqual value: ')', scopes: scopeStack.concat ['punctuation.definition.parameters.end.bracket.round.java']
    expect(lines[4][11]).toEqual value: '{', scopes: scopeStack.concat ['punctuation.section.catch.begin.bracket.curly.java']

    scopeStack.push 'meta.catch.body.java'
    expect(lines[5][1]).toEqual value: 'handleRuntimeException', scopes: scopeStack.concat ['meta.function-call.java', 'entity.name.function.java']

    scopeStack.pop()
    expect(lines[6][1]).toEqual value: '}', scopes: scopeStack.concat ['punctuation.section.catch.end.bracket.curly.java']
    expect(lines[6][3]).toEqual value: 'catch', scopes: scopeStack.concat ['keyword.control.catch.java']
    expect(lines[6][5]).toEqual value: '(', scopes: scopeStack.concat ['punctuation.definition.parameters.begin.bracket.round.java']
    scopeStack.push 'meta.catch.parameters.java'
    expect(lines[6][6]).toEqual value: 'Exception', scopes: scopeStack.concat ['storage.type.java']
    expect(lines[6][8]).toEqual value: 'e', scopes: scopeStack.concat ['variable.parameter.java']
    scopeStack.pop()
    expect(lines[6][9]).toEqual value: ')', scopes: scopeStack.concat ['punctuation.definition.parameters.end.bracket.round.java']
    expect(lines[6][11]).toEqual value: '{', scopes: scopeStack.concat ['punctuation.section.catch.begin.bracket.curly.java']

    scopeStack.push 'meta.catch.body.java'
    expect(lines[7][1]).toEqual value: 'String', scopes: scopeStack.concat ['meta.definition.variable.java', 'storage.type.java']
    expect(lines[7][3]).toEqual value: 'variable', scopes: scopeStack.concat ['meta.definition.variable.java', 'variable.definition.java']

    scopeStack.pop()
    expect(lines[8][1]).toEqual value: '}', scopes: scopeStack.concat ['punctuation.section.catch.end.bracket.curly.java']
    scopeStack.pop()
    scopeStack.push 'meta.finally.java'
    expect(lines[8][3]).toEqual value: 'finally', scopes: scopeStack.concat ['keyword.control.finally.java']
    expect(lines[8][5]).toEqual value: '{', scopes: scopeStack.concat ['punctuation.section.finally.begin.bracket.curly.java']

    scopeStack.push 'meta.finally.body.java'
    expect(lines[9][1]).toEqual value: '//', scopes: scopeStack.concat ['comment.line.double-slash.java', 'punctuation.definition.comment.java']

    expect(lines[10][1]).toEqual value: 'new', scopes: scopeStack.concat ['keyword.control.new.java']

    scopeStack.pop()
    expect(lines[11][1]).toEqual value: '}', scopes: scopeStack.concat ['punctuation.section.finally.end.bracket.curly.java']

  it 'tokenizes nested try-catch-finally blocks', ->
    lines = grammar.tokenizeLines '''
    class Test {
      public void fn() {
        try {
          try {
            String nested;
          } catch (Exception e) {
            handleNestedException();
          }
        } catch (RuntimeException re) {}
      }
    }
    '''

    scopeStack = ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.method.java', 'meta.method.body.java']

    scopeStack.push 'meta.try.java'
    expect(lines[2][1]).toEqual value: 'try', scopes: scopeStack.concat ['keyword.control.try.java']
    expect(lines[2][2]).toEqual value: ' ', scopes: scopeStack
    expect(lines[2][3]).toEqual value: '{', scopes: scopeStack.concat ['punctuation.section.try.begin.bracket.curly.java']

    scopeStack.push 'meta.try.body.java', 'meta.try.java'
    expect(lines[3][1]).toEqual value: 'try', scopes: scopeStack.concat ['keyword.control.try.java']
    expect(lines[3][2]).toEqual value: ' ', scopes: scopeStack
    expect(lines[3][3]).toEqual value: '{', scopes: scopeStack.concat ['punctuation.section.try.begin.bracket.curly.java']

    scopeStack.push 'meta.try.body.java'
    expect(lines[4][1]).toEqual value: 'String', scopes: scopeStack.concat ['meta.definition.variable.java', 'storage.type.java']
    expect(lines[4][3]).toEqual value: 'nested', scopes: scopeStack.concat ['meta.definition.variable.java', 'variable.definition.java']

    scopeStack.pop()
    expect(lines[5][1]).toEqual value: '}', scopes: scopeStack.concat ['punctuation.section.try.end.bracket.curly.java']
    scopeStack.pop()
    expect(lines[5][2]).toEqual value: ' ', scopes: scopeStack
    scopeStack.push 'meta.catch.java'
    expect(lines[5][3]).toEqual value: 'catch', scopes: scopeStack.concat ['keyword.control.catch.java']
    expect(lines[5][4]).toEqual value: ' ', scopes: scopeStack
    expect(lines[5][5]).toEqual value: '(', scopes: scopeStack.concat ['punctuation.definition.parameters.begin.bracket.round.java']
    scopeStack.push 'meta.catch.parameters.java'
    expect(lines[5][6]).toEqual value: 'Exception', scopes: scopeStack.concat ['storage.type.java']
    expect(lines[5][7]).toEqual value: ' ', scopes: scopeStack
    expect(lines[5][8]).toEqual value: 'e', scopes: scopeStack.concat ['variable.parameter.java']
    scopeStack.pop()
    expect(lines[5][9]).toEqual value: ')', scopes: scopeStack.concat ['punctuation.definition.parameters.end.bracket.round.java']
    expect(lines[5][10]).toEqual value: ' ', scopes: scopeStack
    expect(lines[5][11]).toEqual value: '{', scopes: scopeStack.concat ['punctuation.section.catch.begin.bracket.curly.java']

    scopeStack.push 'meta.catch.body.java'
    expect(lines[6][1]).toEqual value: 'handleNestedException', scopes: scopeStack.concat ['meta.function-call.java', 'entity.name.function.java']

    scopeStack.pop()
    expect(lines[7][1]).toEqual value: '}', scopes: scopeStack.concat ['punctuation.section.catch.end.bracket.curly.java']

    scopeStack.pop()
    scopeStack.pop()
    expect(lines[8][1]).toEqual value: '}', scopes: scopeStack.concat ['punctuation.section.try.end.bracket.curly.java']
    scopeStack.pop()
    expect(lines[8][2]).toEqual value: ' ', scopes: scopeStack
    scopeStack.push 'meta.catch.java'
    expect(lines[8][3]).toEqual value: 'catch', scopes: scopeStack.concat ['keyword.control.catch.java']
    expect(lines[8][4]).toEqual value: ' ', scopes: scopeStack
    expect(lines[8][5]).toEqual value: '(', scopes: scopeStack.concat ['punctuation.definition.parameters.begin.bracket.round.java']
    scopeStack.push 'meta.catch.parameters.java'
    expect(lines[8][6]).toEqual value: 'RuntimeException', scopes: scopeStack.concat ['storage.type.java']
    expect(lines[8][7]).toEqual value: ' ', scopes: scopeStack
    expect(lines[8][8]).toEqual value: 're', scopes: scopeStack.concat ['variable.parameter.java']
    scopeStack.pop()
    expect(lines[8][9]).toEqual value: ')', scopes: scopeStack.concat ['punctuation.definition.parameters.end.bracket.round.java']
    expect(lines[8][10]).toEqual value: ' ', scopes: scopeStack
    expect(lines[8][11]).toEqual value: '{', scopes: scopeStack.concat ['punctuation.section.catch.begin.bracket.curly.java']
    expect(lines[8][12]).toEqual value: '}', scopes: scopeStack.concat ['punctuation.section.catch.end.bracket.curly.java']
