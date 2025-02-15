{
  'target_defaults': {
    'conditions': [
      ['OS=="mac"', {
        'xcode_settings': {
          'OTHER_CPLUSPLUSFLAGS': ['-std=c++20']
        }
      }]
    ]
  }
}
