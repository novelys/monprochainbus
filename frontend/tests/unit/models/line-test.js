import { moduleForModel, test } from 'ember-qunit';

moduleForModel('line', 'Unit | Model | line', {
  // Specify the other units that are required for this test.
  needs: ['model:stop', 'model:line-direction']
});

test('it exists', function(assert) {
  let model = this.subject();
  // let store = this.store();
  assert.ok(!!model);
});
