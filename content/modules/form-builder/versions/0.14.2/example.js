var form = new hx.Form('#form')
  .addText('Text', { required:true, placeholder:'Name' })
  .addTextArea('Text Area', { placeholder:'Name' })
  .addEmail('Email', { required:true, placeholder:'your.name@ocado.com' })
  .addUrl('Url', { placeholder:'http://www.example.co.uk/' }) // Allows blank or valid URL (with http:// prefix)
  .addNumber('Number', {required:true})
  .addPicker('Select', ['red', 'green', 'blue'])
  .addCheckbox('Checkbox')
  .addPassword('Password')
  .addRadio('Radio', ['One', 'Two', 'Three'])
  .addTagInput('Tag Input')
  .addDatePicker('Date Picker')
  .addTimePicker('Time Picker')
  .addDateTimePicker('Date Time Picker')
  .addSubmit('Submit', 'hx-icon hx-icon-check')
  .on('submit', function(data){console.log(data)});

var radioNode = hx.select(form.properties.get('Radio').node)
radioNode.selectAll('input').on('click', function(e) {
  console.log( form.property('Radio') );
})