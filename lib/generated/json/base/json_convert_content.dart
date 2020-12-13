// ignore_for_file: non_constant_identifier_names
// ignore_for_file: camel_case_types
// ignore_for_file: prefer_single_quotes

// This file is automatically generated. DO NOT EDIT, all your changes would be lost.
import 'package:flutter_unit/big_datas_entity.dart';
import 'package:flutter_unit/generated/json/big_datas_entity_helper.dart';
import 'package:flutter_unit/model/time_line_model_entity.dart';
import 'package:flutter_unit/generated/json/time_line_model_entity_helper.dart';
import 'package:flutter_unit/big_data_menu_entity.dart';
import 'package:flutter_unit/generated/json/big_data_menu_entity_helper.dart';

class JsonConvert<T> {
	T fromJson(Map<String, dynamic> json) {
		return _getFromJson<T>(runtimeType, this, json);
	}

  Map<String, dynamic> toJson() {
		return _getToJson<T>(runtimeType, this);
  }

  static _getFromJson<T>(Type type, data, json) {
    switch (type) {			case BigDatasEntity:
			return bigDatasEntityFromJson(data as BigDatasEntity, json) as T;			case BigDatasData:
			return bigDatasDataFromJson(data as BigDatasData, json) as T;			case TimeLineModelEntity:
			return timeLineModelEntityFromJson(data as TimeLineModelEntity, json) as T;			case TimeLineModelData:
			return timeLineModelDataFromJson(data as TimeLineModelData, json) as T;			case TimeLineModelDataTimeLine:
			return timeLineModelDataTimeLineFromJson(data as TimeLineModelDataTimeLine, json) as T;			case TimeLineModelDataTimeLineUser:
			return timeLineModelDataTimeLineUserFromJson(data as TimeLineModelDataTimeLineUser, json) as T;			case TimeLineModelDataTimeLineMy:
			return timeLineModelDataTimeLineMyFromJson(data as TimeLineModelDataTimeLineMy, json) as T;			case BigDataMenuEntity:
			return bigDataMenuEntityFromJson(data as BigDataMenuEntity, json) as T;			case BigDataMenuData:
			return bigDataMenuDataFromJson(data as BigDataMenuData, json) as T;    }
    return data as T;
  }

  static _getToJson<T>(Type type, data) {
		switch (type) {			case BigDatasEntity:
			return bigDatasEntityToJson(data as BigDatasEntity);			case BigDatasData:
			return bigDatasDataToJson(data as BigDatasData);			case TimeLineModelEntity:
			return timeLineModelEntityToJson(data as TimeLineModelEntity);			case TimeLineModelData:
			return timeLineModelDataToJson(data as TimeLineModelData);			case TimeLineModelDataTimeLine:
			return timeLineModelDataTimeLineToJson(data as TimeLineModelDataTimeLine);			case TimeLineModelDataTimeLineUser:
			return timeLineModelDataTimeLineUserToJson(data as TimeLineModelDataTimeLineUser);			case TimeLineModelDataTimeLineMy:
			return timeLineModelDataTimeLineMyToJson(data as TimeLineModelDataTimeLineMy);			case BigDataMenuEntity:
			return bigDataMenuEntityToJson(data as BigDataMenuEntity);			case BigDataMenuData:
			return bigDataMenuDataToJson(data as BigDataMenuData);    }
    return data as T;
  }
  //Go back to a single instance by type
  static _fromJsonSingle(String type, json) {
    switch (type) {			case 'BigDatasEntity':
			return BigDatasEntity().fromJson(json);			case 'BigDatasData':
			return BigDatasData().fromJson(json);			case 'TimeLineModelEntity':
			return TimeLineModelEntity().fromJson(json);			case 'TimeLineModelData':
			return TimeLineModelData().fromJson(json);			case 'TimeLineModelDataTimeLine':
			return TimeLineModelDataTimeLine().fromJson(json);			case 'TimeLineModelDataTimeLineUser':
			return TimeLineModelDataTimeLineUser().fromJson(json);			case 'TimeLineModelDataTimeLineMy':
			return TimeLineModelDataTimeLineMy().fromJson(json);			case 'BigDataMenuEntity':
			return BigDataMenuEntity().fromJson(json);			case 'BigDataMenuData':
			return BigDataMenuData().fromJson(json);    }
    return null;
  }

  //empty list is returned by type
  static _getListFromType(String type) {
    switch (type) {			case 'BigDatasEntity':
			return List<BigDatasEntity>();			case 'BigDatasData':
			return List<BigDatasData>();			case 'TimeLineModelEntity':
			return List<TimeLineModelEntity>();			case 'TimeLineModelData':
			return List<TimeLineModelData>();			case 'TimeLineModelDataTimeLine':
			return List<TimeLineModelDataTimeLine>();			case 'TimeLineModelDataTimeLineUser':
			return List<TimeLineModelDataTimeLineUser>();			case 'TimeLineModelDataTimeLineMy':
			return List<TimeLineModelDataTimeLineMy>();			case 'BigDataMenuEntity':
			return List<BigDataMenuEntity>();			case 'BigDataMenuData':
			return List<BigDataMenuData>();    }
    return null;
  }

  static M fromJsonAsT<M>(json) {
    String type = M.toString();
    if (json is List && type.contains("List<")) {
      String itemType = type.substring(5, type.length - 1);
      List tempList = _getListFromType(itemType);
      json.forEach((itemJson) {
        tempList
            .add(_fromJsonSingle(type.substring(5, type.length - 1), itemJson));
      });
      return tempList as M;
    } else {
      return _fromJsonSingle(M.toString(), json) as M;
    }
  }
}