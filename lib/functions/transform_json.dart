Map<String, dynamic> transformJson(Map<String, dynamic> json) {
  Map<String, dynamic> output = {};
  Map<String, dynamic> servicio = {};
  Map<String, dynamic> children = {};

  void innerTransform(List<dynamic> list, String parentKey) {
    for (var item in list) {
      if (item is Map) {
        List<String> keys = List<String>.from(item.keys);
        for (var key in keys) {
          var value = item[key];
          if (value is List && value.isNotEmpty && value.first is Map) {
            children.putIfAbsent(key, () => []).addAll(value);
            item.remove(key);
            output.putIfAbsent(parentKey, () => []);
            output[parentKey]!.add(item);
          }
        }
      }
    }
  }

  json.forEach((key, value) {
    if (value is Map) {
      output[key] = [value];
    }
    // ignore: type_check_with_null
    if (value is num || value is String || value is Null || value is double) {
      servicio[key] = value;
    }
    if (value is List) {
      innerTransform(value, key);
      output[key] = value;
    }
  });

  children.forEach((key, list) {
    if (!output.containsKey(key)) {
      output[key] = list;
    }
  });

  if (servicio.isNotEmpty) {
    output["Servicio"] = [servicio];
  }

  return output;
}
