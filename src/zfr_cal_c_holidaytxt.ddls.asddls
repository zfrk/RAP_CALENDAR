@EndUserText.label: 'Projection view for public holiday text'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZFR_CAL_C_HOLIDAYTXT
  as projection on Zfr_CAL_I_HOLIDAYTXT
{
  @Consumption.valueHelpDefinition: [ {entity: {name: 'I_Language', element: 'Language' }} ]
  @ObjectModel.text.element:['LanguageDescription']
  key Language,
  key HolidayId,
      HolidayDescription,
      _LanguageText.LanguageName as LanguageDescription : localized,
      _Public_Holiday : redirected to parent ZFR_CAL_C_HOLIDAY
}
