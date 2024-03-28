import 'package:barrier_free/component/appBar.dart';
import 'package:barrier_free/component/facility_button.dart';
import 'package:barrier_free/const/color.dart';
import 'package:barrier_free/screen/map/mapresult_screen.dart';
import 'package:barrier_free/services/location_service.dart';
import 'package:barrier_free/services/place_service.dart';
import 'package:barrier_free/services/search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';

import '../../component/map_markers.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late TextEditingController _originController = TextEditingController();
  late List<dynamic> allPlaces = [];
  late List<dynamic> filteredPlaces = [];
  late List<dynamic> searchResults = [];
  Position? _currentPosition;

  String customScript = '';

  Map<String, List<dynamic>> categorizedPlaces = {};

  @override
  void initState() {
    super.initState();
    _originController = TextEditingController();
    // 초기화
    allPlaces = [];
    filteredPlaces = [];
    _initializeLocation().then((_) {
      _loadPlaces(); // _initializeLocation 완료 후 _loadPlaces 호출
    });
    // _initializeLocation();
    // _loadPlaces();
  }

  //
  Future<Position?> _initializeLocation() async {
    try {
      Position position = await LocationService().getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
      print(
          '================================initialize=================================');
      print(position);
      print(
          '=================================================================');
      return position;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> _search() async {
    if (_originController.text.isNotEmpty) {
      try {
        final result = await fetchSearchResults(_originController.text);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapResultScreen(
              searchResults: result,
              keyWord: _originController.text,
              currentPosition: _currentPosition!,
            ),
          ),
        );
        print(
            '=================================================================');
        print(result);
        //검색결과 화면에 표시 로직 짜기
      } catch (e) {
        print("============= 검색 실패임: $e =============");
      }
    }
  }

  void _loadPlaces() async {
    if (_currentPosition != null) {
      String lat = _currentPosition!.latitude.toString();
      String lng = _currentPosition!.longitude.toString();

      try {
        List<dynamic> places =
            await PlaceService().fetchPlacesByCategory(lat, lng);
        print(places);

        Map<String, List<dynamic>> newCategorizedPlaces = {};

        //장소 카테고리별로 분리하기
        for (var place in places) {
          String category = place['category'];
          if (!newCategorizedPlaces.containsKey(category)) {
            newCategorizedPlaces[category] = [];
          }
          newCategorizedPlaces[category]!.add(place);
        }

        setState(() {
          allPlaces = places;
          categorizedPlaces = newCategorizedPlaces; // 상태 업데이트
        });

        categorizedPlaces.forEach((category, places) {
          print('$category:${places.length}');
        });
      } catch (e) {
        print(e);
      }
    }
  }

  void _onCategoryFiltered(String category) {
    // 선택한 버튼 카테고리로 장소 필터링
    List<dynamic> filteredPlaces =
        // allPlaces.where((place) => place['category'] == category).toList();
        categorizedPlaces[category] ?? [];

    // JavaScript 코드를 생성하여 마커를 업데이트
    String script = """
    var markers = []; // 마커 배열 초기화
    var infowindows = [];
    var bounds = new kakao.maps.LatLngBounds(); // 지도 범위 객체 생성
    var currentInfowindow = null;
    var closeTimeout;

function closeCurrentInfowindow(){
    if(currentInfowindow) {
      currentInfowindow.close();
    }
    if(closeTimeout) {
      clearTimeout(closeTimeout);
    }
    currentInfowindow = null;
  }
  
    function openInfowindow(marker, infowindow){
      closeCurrentInfowindow();
      infowindow.open(map, marker);
      currentInfowindow = infowindow;
      closeTimeout = setTimeout(function() {
        if (currentInfowindow !== null) {
          closeCurrentInfowindow();
        }
      }, 3000);
      
    }
    
    
  ${filteredPlaces.map((place) => '''
    var position = new kakao.maps.LatLng(${place['lat']}, ${place['lng']});
    var marker = new kakao.maps.Marker({
      position: position,
      map: map
    });

    var content = '<div style="padding:5px;min-width:150px;text-align:center;">${place['placeName']}</div>';
    var infowindow = new kakao.maps.InfoWindow({
      content: content
    });
     kakao.maps.event.addListener(marker, 'click', function() {
       openInfowindow(marker, infowindow); 
    });

    markers.push(marker);
    infowindows.push(infowindow);
    bounds.extend(position);
  ''').join('')}

  map.setBounds(bounds);
  """;

    setState(() {
      customScript = script;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appKey = dotenv.env['APP_KEY'];

    return FutureBuilder<Position?>(
      future:
          Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //로딩화면 맵 불러올때까지 로딩
                SpinKitPouringHourGlassRefined(
                  color: mainOrange,
                  size: 70.0,
                  duration: Duration(seconds: 1),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Text(
                  'Loading',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: mainOrange,
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('위치를 가져오는 중 오류가 발생했습니다: ${snapshot.error}');
        } else if (snapshot.data != null) {
          final position = snapshot.data!;
          if (appKey == null) {
            return const Text('환경 변수에서 앱 키를 불러올 수 없습니다.');
          }
          return Scaffold(
            appBar: const CustomAppBar(
              title: '베프.',
              titleStyle: TextStyle(
                fontFamily: 'LogoFont',
                fontSize: 32.0,
              ),
            ),
            body: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(30.0)),
                      border: Border.all(color: mainOrange, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: const Offset(3, 3))
                      ]),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                            hintText: '검색어를 입력해주세요.',
                            hintStyle: TextStyle(
                                color: mainGray, fontWeight: FontWeight.w600),
                            border:
                                OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                          textCapitalization: TextCapitalization.words,
                          controller: _originController,
                          onChanged: (value) {
                            print(value);
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: _search,
                        icon: const Icon(
                          Icons.search,
                          color: mainOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      KakaoMapView(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        kakaoMapKey: appKey!,
                        lat: position.latitude,
                        lng: position.longitude,
                        markerImageURL:
                            'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/marker_red.png',
                        showZoomControl: false,
                        showMapTypeControl: false,
                        customScript: customScript,
                      ),
                      Positioned(
                        top: 8.0, // 위치 조정 가능
                        left: 0,
                        right: 0,
                        child: CustomFacilityButton(
                          onFeatureSelected: _onCategoryFiltered,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: Text('데이터를 불러오는 중 문제가 발생했습니다.'),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _originController.dispose();
    super.dispose();
  }
}
