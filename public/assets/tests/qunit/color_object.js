QUnit.test('test color object', assert => {
  let hex = new App.ColorObject('#09f609')
  let hsl = new App.ColorObject([0.5, 0.2, 0.3])

  assert.deepEqual(hex.asHslArray(), [1/3, 0.9294117647058824, 0.5], 'HEX converted to HSL components')
  assert.deepEqual(hsl.asHslArray(), [0.5, 0.2, 0.3], 'HSL components returned as original input')
  assert.equal(hex.asString(), '#09f609', 'HEX represented as original input')
  assert.equal(hsl.asString(), 'hsl(180,20%,30%)', 'HSL components represented as HSL string')

  hex.updateWithString('#fff')
  assert.equal(hex.asString(), '#fff', 'color updated')

  hsl.updateWithHslComponent(0.25, 1)
  assert.deepEqual(hsl.asHslArray(), [0.5, 0.25, 0.3], 'given HSL component updated')

  assert.deepEqual(Array.from(App.ColorObject.anyToRgb('#ff0000')), [255, 0, 0, 255], 'any to RGB')
  assert.deepEqual(App.ColorObject.anyToHslArray('#ff0000'), [0,1,0.5], 'any to HSL components')
  assert.equal(App.ColorObject.anyToHslString('#ff0000'), 'hsl(0,100%,50%)', 'any to HSL string')
  assert.deepEqual(App.ColorObject.rgbToHslArray([255, 0, 0]), [0,1,0.5], 'RGB to HSL components')
  assert.equal(App.ColorObject.hslArrayToHslString([0.5, 0.25, 0.3]), 'hsl(180,25%,30%)', 'HSL components to HSL string')
})
