String convertChargerType(String code) {
  switch (code) {
    case "01":
      return "완속";
    case "02":
      return "급속";
    case "03":
      return "초급속";
    case "06":
      return "DC차데모";
    case "07":
      return "AC3상";
    default:
      return "기타";
  }
}
