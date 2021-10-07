import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Ads extends StatefulWidget {
  Ads({Key? key}) : super(key: key);

  @override
  _AdsState createState() => _AdsState();
}

class _AdsState extends State<Ads> {
  BannerAd? _myBanner;
  bool? isLoaded;

  // String get _adUnitTestID => "ca-app-pub-3940256099942544/6300978111";
  String get _adUnitID => "ca-app-pub-1612399077386662/6227262426";
  @override
  void initState() {
    super.initState();
    _myBanner = BannerAd(
      adUnitId: _adUnitID,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          // print('Ad loaded: ${ad.adUnitId}');
          setState(() {
            isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad Failed to loaded: ${ad.adUnitId}, $error');
        },
        onAdOpened: (ad) => print(
          'Ad Opened: ${ad.adUnitId}',
        ),
        onAdImpression: (ad) =>
            print('every impression counts ${ad.responseInfo}'),
      ),
    );
    _myBanner!.load();
  }

  Widget checkForAd() {
    if (isLoaded == true) {
      return Container(
        child: AdWidget(
          ad: _myBanner!,
        ),
        decoration: BoxDecoration(
            // boxShadow: [
            //   BoxShadow(
            //     color: Theme.of(context).primaryColor,
            //     blurRadius: 3,
            //     offset: Offset(0, 0),
            //   ),
            // ],
            ),
        width: _myBanner!.size.width.toDouble(),
        height: 72.0,
        alignment: Alignment.center,
      );
    } else {
      return LinearProgressIndicator(
        color: Theme.of(context).primaryColor,
        minHeight: 2,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();

    _myBanner!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return checkForAd();
  }
}
