var form = new hx.Form('#form')
  .addText('Text', {required:true, placeholder:'Name'})
  .addEmail('Email', {required:true, placeholder:'your.name@ocado.com'})
  .addUrl('Url', {placeholder:'http://www.example.co.uk/'}) // Allows blank or valid URL (with http:// prefix)
  .addNumber('Number', {required:true})
  .addSelect('Default Select', ['red', 'green', 'blue'])
  .addSelect('Select Blank Start', ['cyan', 'magenta', 'yellow'], {required: false})
  .addSelect('Required Select', ['hue', 'saturation', 'lightness'], {required: true}) // Will not validate unless a value is selected
  .addCheckbox('Checkbox')
  .addPassword('Password')
  .addRadio('Radio', ['One', 'Two', 'Three'], {required: true})
  .addTagInput('Tag Input')
  .addSubmit('Submit', 'hx-icon hx-icon-check')
  .on('submit', function(data){console.log(data)});