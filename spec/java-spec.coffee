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

    expect(tokens[1]).toEqual value: '(', scopes: ['source.java', 'meta.method-call.java', 'punctuation.definition.method-parameters.begin.bracket.round.java']
    expect(tokens[3]).toEqual value: ')', scopes: ['source.java', 'meta.method-call.java', 'punctuation.definition.method-parameters.end.bracket.round.java']

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

    expect(tokens[1]).toEqual value: '.', scopes: ['source.java', 'punctuation.separator.period.java']
    expect(tokens[5]).toEqual value: ',', scopes: ['source.java', 'meta.method-call.java', 'punctuation.separator.delimiter.java']
    expect(tokens[8]).toEqual value: ',', scopes: ['source.java', 'meta.method-call.java', 'punctuation.separator.delimiter.java']
    expect(tokens[11]).toEqual value: ';', scopes: ['source.java', 'punctuation.terminator.java']

    {tokens} = grammar.tokenizeLine 'a . b'

    expect(tokens[1]).toEqual value: '.', scopes: ['source.java', 'punctuation.separator.period.java']

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

  it 'tokenizes generics', ->
    lines = grammar.tokenizeLines '''
      class A<T extends A & B, String, Integer>
      {
        HashMap<Integer, String> map = new HashMap<>();
        CodeMap<String, ? extends ArrayList> codemap;
        C(Map<?, ? extends List<?>> m) {}
        Map<Integer, String> method() {}
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

  it 'tokenizes arrow operator', ->
    {tokens} = grammar.tokenizeLine '(String s1) -> s1.length() - outer.length();'

    expect(tokens[1]).toEqual value: 'String', scopes: ['source.java', 'storage.type.java']
    expect(tokens[5]).toEqual value: '->', scopes: ['source.java', 'storage.type.function.arrow.java']
    expect(tokens[7]).toEqual value: '.', scopes: ['source.java', 'punctuation.separator.period.java']
    expect(tokens[9]).toEqual value: '(', scopes: ['source.java', 'meta.method-call.java', 'punctuation.definition.method-parameters.begin.bracket.round.java']
    expect(tokens[10]).toEqual value: ')', scopes: ['source.java', 'meta.method-call.java', 'punctuation.definition.method-parameters.end.bracket.round.java']
    expect(tokens[12]).toEqual value: '-', scopes: ['source.java', 'keyword.operator.arithmetic.java']

  it 'tokenizes the `instanceof` operator', ->
    {tokens} = grammar.tokenizeLine 'instanceof'

    expect(tokens[0]).toEqual value: 'instanceof', scopes: ['source.java', 'keyword.operator.instanceof.java']

  it 'tokenizes class fields', ->
    {tokens} = grammar.tokenizeLine '''
      class A {
        private int uninitialized;
        private int initialized = 12;
      }
    '''
    expect(tokens[10]).toEqual value: 'uninitialized', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'meta.definition.variable.name.java']
    expect(tokens[17]).toEqual value: 'initialized', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'meta.definition.variable.name.java']
    expect(tokens[19]).toEqual value: '=', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'keyword.operator.assignment.java']
    expect(tokens[21]).toEqual value: '12', scopes: ['source.java', 'meta.class.java', 'meta.class.body.java', 'meta.definition.variable.java', 'constant.numeric.java']

  it 'tokenizes primitives', ->
    {tokens} = grammar.tokenizeLine 'private int plainInt'
    expect(tokens[2]).toEqual value: 'int', scopes: ['source.java', 'storage.type.primitive.java']

  it 'tokenizes primitive arrays', ->
    {tokens} = grammar.tokenizeLine 'private int[] intarray'
    expect(tokens[2]).toEqual value: 'int', scopes: ['source.java', 'storage.type.primitive.array.java']
