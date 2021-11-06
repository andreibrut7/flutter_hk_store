import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutterstore/config/ps_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutterstore/constant/ps_dimens.dart';
import 'package:flutterstore/ui/common/ps_ui_widget.dart';
import 'package:flutterstore/viewobject/default_photo.dart';

class ProductImageSliderView extends StatefulWidget {
  const ProductImageSliderView({
    Key key,
    @required this.photoList,
    this.onTap,
  }) : super(key: key);

  final Function onTap;
  final List<DefaultPhoto> photoList;

  @override
  _ProductImageSliderViewState createState() => _ProductImageSliderViewState();
}

class _ProductImageSliderViewState extends State<ProductImageSliderView> {
  String _currentId;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[

        if (widget.photoList != null && widget.photoList.isNotEmpty)
          if (widget.photoList.length == 1)
            CarouselSlider(
              options: CarouselOptions(
                  enlargeCenterPage: true,
                  autoPlay: false,
                  enableInfiniteScroll: false,
                  height: double.infinity,
                  viewportFraction: 0.8,
                  autoPlayInterval: const Duration(seconds: 5),
                  onPageChanged: (int i, CarouselPageChangedReason reason) {
                    setState(() {
                      _currentId = widget.photoList[i].imgId;
                    });
                  }),

              items: widget.photoList.map((DefaultPhoto defaultPhoto) {
                return Container(
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //     // color: PsColors.mainLightShadowColor,
                  //   ),
                  //   borderRadius:
                  //       const BorderRadius.all(Radius.circular(PsDimens.space8)),
                  //   boxShadow: <BoxShadow>[
                  //     BoxShadow(
                  //         color: PsColors.mainLightShadowColor,
                  //         offset: const Offset(1.1, 1.1),
                  //         blurRadius: PsDimens.space8),
                  //   ],
                  // ),
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                        // borderRadius: BorderRadius.circular(PsDimens.space8),
                        child: PsNetworkImage(
                            photoKey: '',
                            defaultPhoto: defaultPhoto,
                            width: MediaQuery.of(context).size.width,
                            height: double.infinity,
                            onTap: () {
                              widget.onTap(defaultPhoto);
                            }),
                      ),
                    ],
                  ),
                );
              }).toList(),
              // onPageChanged: (int i) {
              //   setState(() {
              //     _currentId = widget.collectionProductList[i].id;
              //   });
              // },
            )
          else
            CarouselSlider(
              options: CarouselOptions(
                  enlargeCenterPage: true,
                  autoPlay: true,
                  height: double.infinity,
                  viewportFraction: 0.8,
                  autoPlayInterval: const Duration(seconds: 5),
                  onPageChanged: (int i, CarouselPageChangedReason reason) {
                    setState(() {
                      _currentId = widget.photoList[i].imgId;
                    });
                  }),

              items: widget.photoList.map((DefaultPhoto defaultPhoto) {
                return Container(
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //     // color: PsColors.mainLightShadowColor,
                  //   ),
                  //   borderRadius:
                  //       const BorderRadius.all(Radius.circular(PsDimens.space8)),
                  //   boxShadow: <BoxShadow>[
                  //     BoxShadow(
                  //         color: PsColors.mainLightShadowColor,
                  //         offset: const Offset(1.1, 1.1),
                  //         blurRadius: PsDimens.space8),
                  //   ],
                  // ),
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                        // borderRadius: BorderRadius.circular(PsDimens.space8),
                        child: PsNetworkImage(
                            photoKey: '',
                            defaultPhoto: defaultPhoto,
                            width: MediaQuery.of(context).size.width,
                            height: double.infinity,
                            onTap: () {
                              widget.onTap(defaultPhoto);
                            }),
                      ),
                    ],
                  ),
                );
              }).toList(),
              // onPageChanged: (int i) {
              //   setState(() {
              //     _currentId = widget.collectionProductList[i].id;
              //   });
              // },
            )
        else
          Container(),
        Positioned(
            bottom: 5.0,
            left: 0.0,
            right: 0.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.photoList != null && widget.photoList.isNotEmpty
                  ? widget.photoList.map((DefaultPhoto defaultPhoto) {
                      return Builder(builder: (BuildContext context) {
                        return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 2.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentId == defaultPhoto.imgId
                                    ? PsColors.mainColor
                                    : PsColors.grey));
                      });
                    }).toList()
                  : <Widget>[Container()],
            ))
      ],
    );
  }
}
