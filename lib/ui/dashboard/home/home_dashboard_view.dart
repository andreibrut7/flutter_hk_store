import 'package:flutterstore/config/ps_colors.dart';
import 'package:flutterstore/config/ps_config.dart';
import 'package:flutterstore/constant/ps_constants.dart';
import 'package:flutterstore/provider/category/trending_category_provider.dart';
import 'package:flutterstore/provider/product/discount_product_provider.dart';
import 'package:flutterstore/provider/product/feature_product_provider.dart';
import 'package:flutterstore/provider/product/search_product_provider.dart';
import 'package:flutterstore/provider/product/trending_product_provider.dart';
import 'package:flutterstore/provider/productcollection/product_collection_provider.dart';
import 'package:flutterstore/provider/shop_info/shop_info_provider.dart';
import 'package:flutterstore/repository/Common/notification_repository.dart';
import 'package:flutterstore/repository/product_collection_repository.dart';
import 'package:flutterstore/repository/shop_info_repository.dart';
import 'package:flutterstore/ui/category/item/category_horizontal_list_item.dart';
import 'package:flutterstore/ui/category/item/category_horizontal_trending_list_item.dart';
import 'package:flutterstore/ui/common/ps_frame_loading_widget.dart';
import 'package:flutterstore/ui/common/dialog/noti_dialog.dart';
import 'package:flutterstore/ui/dashboard/home/collection_product_slider.dart';
import 'package:flutterstore/ui/product/collection_product/product_list_by_collection_id_view.dart';
import 'package:flutterstore/ui/product/item/product_horizontal_list_item.dart';
import 'package:flutterstore/ui/product/item/latest_product_new.dart';
import 'package:flutterstore/utils/utils.dart';
import 'package:flutterstore/viewobject/common/ps_value_holder.dart';
import 'package:flutterstore/viewobject/holder/category_parameter_holder.dart';
import 'package:flutterstore/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:flutterstore/viewobject/holder/intent_holder/product_list_intent_holder.dart';
import 'package:flutterstore/viewobject/holder/product_parameter_holder.dart';
import 'package:flutterstore/viewobject/holder/touch_count_parameter_holder.dart';
import 'package:flutterstore/viewobject/product.dart';
import 'package:flutterstore/viewobject/product_collection_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutterstore/api/common/ps_status.dart';
import 'package:flutterstore/constant/ps_dimens.dart';
import 'package:flutterstore/constant/route_paths.dart';
import 'package:flutterstore/provider/category/category_provider.dart';
import 'package:flutterstore/repository/category_repository.dart';
import 'package:flutterstore/repository/product_repository.dart';

class HomeDashboardViewWidget extends StatefulWidget {
  const HomeDashboardViewWidget(this._scrollController,
      this.animationController, this.context, this.onNotiClicked);

  final ScrollController _scrollController;
  final AnimationController animationController;
  final BuildContext context;

  final Function onNotiClicked;

  @override
  _HomeDashboardViewWidgetState createState() =>
      _HomeDashboardViewWidgetState();
}

class _HomeDashboardViewWidgetState extends State<HomeDashboardViewWidget> {
  PsValueHolder valueHolder;
  CategoryRepository repo1;
  ProductRepository repo2;
  ProductCollectionRepository repo3;
  ShopInfoRepository shopInfoRepository;
  NotificationRepository notificationRepository;
  CategoryProvider _categoryProvider;
  ShopInfoProvider _shopInfoProvider;
  TrendingCategoryProvider _trendingCategoryProvider;
  SearchProductProvider _searchProductProvider;
  DiscountProductProvider _discountProductProvider;
  TrendingProductProvider _trendingProductProvider;
  FeaturedProductProvider _featuredProductProvider;
  ProductCollectionProvider _productCollectionProvider;
  final int count = 8;
  final CategoryParameterHolder trendingCategory = CategoryParameterHolder();
  final CategoryParameterHolder categoryIconList = CategoryParameterHolder();

  @override
  void initState() {
    super.initState();
    if (_categoryProvider != null) {
      _categoryProvider.loadCategoryList(categoryIconList.toMap());
    }

    widget._scrollController.addListener(() {
      if (widget._scrollController.position.pixels ==
          widget._scrollController.position.maxScrollExtent) {
        _categoryProvider.nextCategoryList(categoryIconList.toMap());
      }
    });
  }

  Future<void> onSelectNotification(String payload) async {
    if (context == null) {
      widget.onNotiClicked(payload);
    } else {
      return showDialog<dynamic>(
        context: context,
        builder: (_) {
          return NotiDialog(message: '$payload');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    repo1 = Provider.of<CategoryRepository>(context);
    repo2 = Provider.of<ProductRepository>(context);
    repo3 = Provider.of<ProductCollectionRepository>(context);
    shopInfoRepository = Provider.of<ShopInfoRepository>(context);
    notificationRepository = Provider.of<NotificationRepository>(context);
    valueHolder = Provider.of<PsValueHolder>(context);

    return MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<ShopInfoProvider>(
              lazy: false,
              create: (BuildContext context) {
                _shopInfoProvider = ShopInfoProvider(
                    repo: shopInfoRepository,
                    psValueHolder: valueHolder,
                    ownerCode: 'HomeDashboardViewWidget');
                _shopInfoProvider.loadShopInfo();
                return _shopInfoProvider;
              }),
          ChangeNotifierProvider<CategoryProvider>(
              lazy: false,
              create: (BuildContext context) {
                _categoryProvider ??= CategoryProvider(
                    repo: repo1,
                    psValueHolder: valueHolder,
                    limit: PsConfig.CATEGORY_LOADING_LIMIT);
                _categoryProvider.loadCategoryList(categoryIconList.toMap());
                return _categoryProvider;
              }),
          ChangeNotifierProvider<TrendingCategoryProvider>(
              lazy: false,
              create: (BuildContext context) {
                _trendingCategoryProvider = TrendingCategoryProvider(
                    repo: repo1,
                    psValueHolder: valueHolder,
                    limit: PsConfig.CATEGORY_LOADING_LIMIT);
                _trendingCategoryProvider
                    .loadTrendingCategoryList(trendingCategory.toMap());
                return _trendingCategoryProvider;
              }),
          ChangeNotifierProvider<SearchProductProvider>(
              lazy: false,
              create: (BuildContext context) {
                _searchProductProvider = SearchProductProvider(
                    repo: repo2, limit: PsConfig.LATEST_PRODUCT_LOADING_LIMIT);
                _searchProductProvider.loadProductListByKey(
                    ProductParameterHolder().getLatestParameterHolder());
                return _searchProductProvider;
              }),
          ChangeNotifierProvider<DiscountProductProvider>(
              lazy: false,
              create: (BuildContext context) {
                _discountProductProvider = DiscountProductProvider(
                    repo: repo2,
                    limit: PsConfig.DISCOUNT_PRODUCT_LOADING_LIMIT);
                _discountProductProvider.loadProductList();
                return _discountProductProvider;
              }),
          ChangeNotifierProvider<TrendingProductProvider>(
              lazy: false,
              create: (BuildContext context) {
                _trendingProductProvider = TrendingProductProvider(
                    repo: repo2,
                    limit: PsConfig.TRENDING_PRODUCT_LOADING_LIMIT);
                _trendingProductProvider.loadProductList();
                return _trendingProductProvider;
              }),
          ChangeNotifierProvider<FeaturedProductProvider>(
              lazy: false,
              create: (BuildContext context) {
                _featuredProductProvider = FeaturedProductProvider(
                    repo: repo2, limit: PsConfig.FEATURE_PRODUCT_LOADING_LIMIT);
                _featuredProductProvider.loadProductList();
                return _featuredProductProvider;
              }),
          ChangeNotifierProvider<ProductCollectionProvider>(
              lazy: false,
              create: (BuildContext context) {
                _productCollectionProvider = ProductCollectionProvider(
                    repo: repo3,
                    limit: PsConfig.COLLECTION_PRODUCT_LOADING_LIMIT);
                _productCollectionProvider.loadProductCollectionList();
                return _productCollectionProvider;
              }),
        ],
        child: Container(
          color: PsColors.coreBackgroundColor,
          child: RefreshIndicator(
            onRefresh: () {
              _productCollectionProvider.resetProductCollectionList();
              _featuredProductProvider.resetProductList();
              _trendingProductProvider.resetProductList();
              _discountProductProvider.resetProductList();
              _searchProductProvider.resetLatestProductList(
                  ProductParameterHolder().getLatestParameterHolder());
              _trendingCategoryProvider
                  .resetTrendingCategoryList(trendingCategory.toMap());
              _categoryProvider.resetCategoryList(categoryIconList.toMap());
              return _shopInfoProvider.loadShopInfo();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              slivers: <Widget>[
                _HomeCollectionProductSliderListWidget(
                  animationController: widget.animationController,

                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / count) * 1, 1.0,
                              curve: Curves.fastOutSlowIn))), //animation
                ),

                ///
                /// category List Widget
                ///
                _HomeCategoryHorizontalListWidget(
                  psValueHolder: valueHolder,
                  animationController: widget.animationController,
                  //animationController,
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / count) * 2, 1.0,
                              curve: Curves.fastOutSlowIn))), //animation
                ),

                _DiscountProductHorizontalListWidget(
                  animationController: widget.animationController,
                  //animationController,
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / count) * 3, 1.0,
                              curve: Curves.fastOutSlowIn))), //animation
                ),



                _HomeLatestProductHorizontalListWidget(
                  animationController: widget.animationController,
                  //animationController,
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / count) * 7, 1.0,
                              curve: Curves.fastOutSlowIn))), //animation
                ),

                /*_HomeTrendingProductHorizontalListWidget(
                  animationController: widget.animationController,
                  //animationController,
                  animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / count) * 8, 1.0,
                              curve: Curves.fastOutSlowIn))), //animation
                ),*/
              ],
            ),
          ),
        ));
  }
}

class _HomeLatestProductHorizontalListWidget extends StatefulWidget {
  const _HomeLatestProductHorizontalListWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  __HomeLatestProductHorizontalListWidgetState createState() =>
      __HomeLatestProductHorizontalListWidgetState();
}

class __HomeLatestProductHorizontalListWidgetState
    extends State<_HomeLatestProductHorizontalListWidget> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SliverToBoxAdapter(
      child: Consumer<SearchProductProvider>(
        builder: (BuildContext context, SearchProductProvider productProvider,
            Widget child) {
          return AnimatedBuilder(
              animation: widget.animationController,
              builder: (BuildContext context, Widget child) {
                return FadeTransition(
                  opacity: widget.animation,
                  child: Transform(
                    transform: Matrix4.translationValues(
                        0.0, 100 * (1.0 - widget.animation.value), 0.0),
                    child: (productProvider.productList.data != null &&
                        productProvider.productList.data.isNotEmpty)
                        ? Column(children: <Widget>[
                      _MyHeaderWidget(
                        headerName: Utils.getString(
                            context, 'dashboard__latest_product'),
                        viewAllClicked: () {
                          Navigator.pushNamed(
                              context, RoutePaths.filterProductList,
                              arguments: ProductListIntentHolder(
                                appBarTitle: Utils.getString(
                                    context, 'dashboard__latest_product'),
                                productParameterHolder:
                                ProductParameterHolder()
                                    .getLatestParameterHolder(),
                              ));
                        },
                      ),
                      Container(
                          height: 3800,
                          width: MediaQuery.of(context).size.width,
                          child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,childAspectRatio: width / (height / 1)),
                              physics: const NeverScrollableScrollPhysics(),
                              //scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(
                                  left: PsDimens.space8),
                              itemCount:
                              20,
                              itemBuilder:
                                  (BuildContext context, int index) {
                                if (productProvider.productList.status ==
                                    PsStatus.BLOCK_LOADING) {
                                  return Shimmer.fromColors(
                                      baseColor: PsColors.grey,
                                      highlightColor: PsColors.white,
                                      child: Row(children: const <Widget>[
                                        PsFrameUIForLoading(),
                                      ]));
                                } else {
                                  final Product product = productProvider
                                      .productList.data[index];
                                  return ProductVerticleListItem(
                                    coreTagKey: productProvider.hashCode
                                        .toString() +
                                        product.id, //'latest',
                                    product: product,
                                    onTap: () async {
                                     //print(product.defaultPhoto.imgPath);

                                      final ProductDetailIntentHolder
                                      holder =
                                      ProductDetailIntentHolder(
                                        product: product,
                                        heroTagImage: productProvider
                                            .hashCode
                                            .toString() +
                                            product.id +
                                            PsConst.HERO_TAG__IMAGE,
                                        heroTagTitle: productProvider
                                            .hashCode
                                            .toString() +
                                            product.id +
                                            PsConst.HERO_TAG__TITLE,
                                        heroTagOriginalPrice: productProvider
                                            .hashCode
                                            .toString() +
                                            product.id +
                                            PsConst
                                                .HERO_TAG__ORIGINAL_PRICE,
                                        heroTagUnitPrice: productProvider
                                            .hashCode
                                            .toString() +
                                            product.id +
                                            PsConst.HERO_TAG__UNIT_PRICE,
                                      );

                                      final dynamic result =
                                      await Navigator.pushNamed(
                                          context,
                                          RoutePaths.productDetail,
                                          arguments: holder);
                                      if (result == null) {
                                        setState(() {
                                          productProvider
                                              .loadProductListByKey(
                                              ProductParameterHolder()
                                                  .getLatestParameterHolder());
                                        });
                                      }
                                    },
                                  );
                                }
                              }))
                    ])
                        : Container(),
                  ),
                );
              });
        },
      ),
    );
  }
}



class _SelectingImageAndTextWidget extends StatelessWidget {
  const _SelectingImageAndTextWidget(
      {Key key,
        @required this.imagePath,
        @required this.title,
        @required this.description,
        @required this.onTap})
      : super(key: key);

  final String imagePath;
  final String title;
  final String description;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Image.asset(
                imagePath,
                width: PsDimens.space60,
                height: PsDimens.space60,
              ),
            ),
            const SizedBox(
              height: PsDimens.space12,
            ),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(
              height: PsDimens.space12,
            ),
            Text(description,
                maxLines: 3,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.caption),
          ],
        ),
      ),
    );
  }
}


class _DiscountProductHorizontalListWidget extends StatefulWidget {
  const _DiscountProductHorizontalListWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  __DiscountProductHorizontalListWidgetState createState() =>
      __DiscountProductHorizontalListWidgetState();
}

class __DiscountProductHorizontalListWidgetState
    extends State<_DiscountProductHorizontalListWidget> {
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;

  void checkConnection() {
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
      if (isConnectedToInternet && PsConfig.showAdMob) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isConnectedToInternet && PsConfig.showAdMob) {
     //print('loading ads....');
      checkConnection();
    }
    return SliverToBoxAdapter(child: Consumer<DiscountProductProvider>(builder:
        (BuildContext context, DiscountProductProvider productProvider,
        Widget child) {
      return AnimatedBuilder(
          animation: widget.animationController,
          builder: (BuildContext context, Widget child) {
            return FadeTransition(
                opacity: widget.animation,
                child: Transform(
                    transform: Matrix4.translationValues(
                        0.0, 100 * (1.0 - widget.animation.value), 0.0),
                    child: (productProvider.productList.data != null &&
                        productProvider.productList.data.isNotEmpty)
                        ? Column(children: <Widget>[
                      _MyHeaderWidget(
                        headerName: Utils.getString(
                            context, 'dashboard__discount_product'),
                        viewAllClicked: () {
                          Navigator.pushNamed(
                              context, RoutePaths.filterProductList,
                              arguments: ProductListIntentHolder(
                                  appBarTitle: Utils.getString(context,
                                      'dashboard__discount_product'),
                                  productParameterHolder:
                                  ProductParameterHolder()
                                      .getDiscountParameterHolder()));
                        },
                      ),
                      Container(
                          height: PsDimens.space320,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(
                                  left: PsDimens.space16),
                              itemCount:
                              productProvider.productList.data.length,
                              itemBuilder:
                                  (BuildContext context, int index) {
                                if (productProvider.productList.status ==
                                    PsStatus.BLOCK_LOADING) {
                                  return Shimmer.fromColors(
                                      baseColor: PsColors.grey,
                                      highlightColor: PsColors.white,
                                      child: Row(children: const <Widget>[
                                        PsFrameUIForLoading(),
                                      ]));
                                } else {
                                  final Product product = productProvider
                                      .productList.data[index];
                                  return ProductHorizontalListItem(
                                    coreTagKey: productProvider.hashCode
                                        .toString() +
                                        product.id,
                                    product: productProvider
                                        .productList.data[index],
                                    onTap: () async {
                                     //print(productProvider.productList.data[index].defaultPhoto.imgPath);
                                      final ProductDetailIntentHolder
                                      holder =
                                      ProductDetailIntentHolder(
                                        product: productProvider
                                            .productList.data[index],
                                        heroTagImage: productProvider
                                            .hashCode
                                            .toString() +
                                            product.id +
                                            PsConst.HERO_TAG__IMAGE,
                                        heroTagTitle: productProvider
                                            .hashCode
                                            .toString() +
                                            product.id +
                                            PsConst.HERO_TAG__TITLE,
                                        heroTagOriginalPrice: productProvider
                                            .hashCode
                                            .toString() +
                                            product.id +
                                            PsConst
                                                .HERO_TAG__ORIGINAL_PRICE,
                                        heroTagUnitPrice: productProvider
                                            .hashCode
                                            .toString() +
                                            product.id +
                                            PsConst.HERO_TAG__UNIT_PRICE,
                                      );
                                      final dynamic result =
                                      await Navigator.pushNamed(
                                          context,
                                          RoutePaths.productDetail,
                                          arguments: holder);
                                      if (result == null) {
                                        setState(() {
                                          productProvider
                                              .loadProductList();
                                        });
                                      }
                                    },
                                  );
                                }
                              })),

                    ])
                        : Container()));
          });
    }));
  }
}

class _HomeCollectionProductSliderListWidget extends StatelessWidget {
  const _HomeCollectionProductSliderListWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    const int count = 6;
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
        parent: animationController,
        curve: const Interval((1 / count) * 1, 1.0,
            curve: Curves.fastOutSlowIn)));

    return SliverToBoxAdapter(
      child: Consumer<ProductCollectionProvider>(builder: (BuildContext context,
          ProductCollectionProvider collectionProvider, Widget child) {
        return AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                  opacity: animation,
                  child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 100 * (1.0 - animation.value), 0.0),
                      child: (collectionProvider.productCollectionList !=
                          null &&
                          collectionProvider
                              .productCollectionList.data.isNotEmpty)
                          ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(

                            margin: const EdgeInsets.only(
                                top: PsDimens.space8,
                                bottom: PsDimens.space20),
                            width: double.infinity,
                            child: CollectionProductSliderView(
                              collectionProductList: collectionProvider
                                  .productCollectionList.data,
                              onTap: (ProductCollectionHeader
                              collectionProduct) {

                              },
                            ),
                          )
                        ],
                      )
                          : Container()));
            });
      }),
    );
  }
}

class _HomeCategoryHorizontalListWidget extends StatefulWidget {
  const _HomeCategoryHorizontalListWidget(
      {Key key,
        @required this.animationController,
        @required this.animation,
        @required this.psValueHolder})
      : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;
  final PsValueHolder psValueHolder;

  @override
  __HomeCategoryHorizontalListWidgetState createState() =>
      __HomeCategoryHorizontalListWidgetState();
}

class __HomeCategoryHorizontalListWidgetState
    extends State<_HomeCategoryHorizontalListWidget> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: Consumer<CategoryProvider>(
      builder: (BuildContext context, CategoryProvider categoryProvider,
          Widget child) {
        return AnimatedBuilder(
            animation: widget.animationController,
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                  opacity: widget.animation,
                  child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 30 * (1.0 - widget.animation.value), 0.0),
                      child: (categoryProvider.categoryList.data != null &&
                          categoryProvider.categoryList.data.isNotEmpty)
                          ? Column(children: <Widget>[
                        _MyHeaderWidgetNew(
                          headerName: Utils.getString(
                              context, 'dashboard__categories'),
                          viewAllClicked: () {

                          },
                        ),
                        Container(
                          height: PsDimens.space72,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.only(
                                  left: PsDimens.space16),
                              scrollDirection: Axis.horizontal,
                              itemCount: categoryProvider
                                  .categoryList.data.length,
                              itemBuilder:
                                  (BuildContext context, int index) {
                                if (categoryProvider
                                    .categoryList.status ==
                                    PsStatus.BLOCK_LOADING) {
                                  return Shimmer.fromColors(
                                      baseColor: PsColors.grey,
                                      highlightColor: PsColors.white,
                                      child: Row(children: const <Widget>[
                                        PsFrameUIForLoading(),
                                      ]));
                                } else {
                                  return CategoryHorizontalListItem(
                                    category: categoryProvider
                                        .categoryList.data[index],
                                    onTap: () {
                                      final String loginUserId =
                                      Utils.checkUserLoginId(
                                          categoryProvider
                                              .psValueHolder);

                                      final TouchCountParameterHolder
                                      touchCountParameterHolder =
                                      TouchCountParameterHolder(
                                          typeId: categoryProvider
                                              .categoryList
                                              .data[index]
                                              .id,
                                          typeName: PsConst
                                              .FILTERING_TYPE_NAME_CATEGORY,
                                          userId: loginUserId);

                                      categoryProvider.postTouchCount(
                                          touchCountParameterHolder
                                              .toMap());

                                     //print(categoryProvider.categoryList.data[index].defaultPhoto.imgPath);
                                      final ProductParameterHolder
                                      productParameterHolder =
                                      ProductParameterHolder()
                                          .getLatestParameterHolder();
                                      productParameterHolder.catId =
                                          categoryProvider.categoryList
                                              .data[index].id;
                                      Navigator.pushNamed(context,
                                          RoutePaths.filterProductList,
                                          arguments:
                                          ProductListIntentHolder(
                                            appBarTitle: categoryProvider
                                                .categoryList
                                                .data[index]
                                                .name,
                                            productParameterHolder:
                                            productParameterHolder,
                                          ));
                                    },
                                  );
                                }
                              }),
                        )
                      ])
                          : Container()));
            });
      },
    ));
  }
}

class _MyHeaderWidget extends StatefulWidget {
  const _MyHeaderWidget({
    Key key,
    @required this.headerName,
    this.productCollectionHeader,
    @required this.viewAllClicked,
  }) : super(key: key);

  final String headerName;
  final Function viewAllClicked;
  final ProductCollectionHeader productCollectionHeader;

  @override
  __MyHeaderWidgetState createState() => __MyHeaderWidgetState();
}

class __MyHeaderWidgetState extends State<_MyHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.viewAllClicked,
      child: Padding(
        padding: const EdgeInsets.only(
            top: PsDimens.space20,
            left: PsDimens.space16,
            right: PsDimens.space16,
            bottom: PsDimens.space10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(widget.headerName,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                      color: PsColors.textPrimaryDarkColor)),
            ),
            Text(
              Utils.getString(context, 'dashboard__view_all'),
              textAlign: TextAlign.start,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(color: PsColors.mainColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyHeaderWidgetNew extends StatefulWidget {
  const _MyHeaderWidgetNew({
    Key key,
    @required this.headerName,
    this.productCollectionHeader,
    @required this.viewAllClicked,
  }) : super(key: key);

  final String headerName;
  final Function viewAllClicked;
  final ProductCollectionHeader productCollectionHeader;

  @override
  __MyHeaderWidgetStateNew createState() => __MyHeaderWidgetStateNew();
}

class __MyHeaderWidgetStateNew extends State<_MyHeaderWidgetNew> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      //onTap: widget.viewAllClicked,
      child: Padding(
        padding: const EdgeInsets.only(
            top: PsDimens.space20,
            left: PsDimens.space16,
            right: PsDimens.space16,
            bottom: PsDimens.space10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(widget.headerName,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                      color: PsColors.textPrimaryDarkColor)),
            ),
          ],
        ),
      ),
    );
  }
}
