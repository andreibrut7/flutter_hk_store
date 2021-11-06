import 'package:flutterstore/config/ps_colors.dart';
import 'package:flutterstore/config/ps_config.dart';

import 'package:flutterstore/constant/ps_dimens.dart';
import 'package:flutterstore/constant/route_paths.dart';
import 'package:flutterstore/provider/basket/basket_provider.dart';
import 'package:flutterstore/repository/basket_repository.dart';
import 'package:flutterstore/ui/common/dialog/confirm_dialog_view.dart';
import 'package:flutterstore/utils/utils.dart';
import 'package:flutterstore/viewobject/basket.dart';
import 'package:flutter/material.dart';

import 'package:flutterstore/viewobject/holder/intent_holder/checkout_intent_holder.dart';
import 'package:flutterstore/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:provider/provider.dart';
import '../item/basket_list_item.dart';

class BasketListView extends StatefulWidget {
  const BasketListView({
    Key key,
    @required this.animationController,
  }) : super(key: key);

  final AnimationController animationController;
  @override
  _BasketListViewState createState() => _BasketListViewState();
}

class _BasketListViewState extends State<BasketListView>
    with SingleTickerProviderStateMixin {
  BasketRepository basketRepo;
  dynamic data;
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;

  void checkConnection() {
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
      if (isConnectedToInternet) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isConnectedToInternet) {

      checkConnection();
    }

    basketRepo = Provider.of<BasketRepository>(context);
    return ChangeNotifierProvider<BasketProvider>(
      lazy: false,
      create: (BuildContext context) {
        final BasketProvider provider = BasketProvider(repo: basketRepo);
        provider.loadBasketList();
        return provider;
      },
      child: Consumer<BasketProvider>(builder:
          (BuildContext context, BasketProvider provider, Widget child) {
        if (provider.basketList != null && provider.basketList.data != null) {
          if (provider.basketList.data.isNotEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[


                Expanded(
                  child: Container(
                      child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: provider.basketList.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      final int count = provider.basketList.data.length;
                      widget.animationController.forward();
                      return BasketListItemView(
                          animationController: widget.animationController,
                          animation:
                              Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: widget.animationController,
                              curve: Interval((1 / count) * index, 1.0,
                                  curve: Curves.fastOutSlowIn),
                            ),
                          ),
                          basket: provider.basketList.data[index],
                          onTap: () {
                            Navigator.pushNamed(
                                context, RoutePaths.productDetail,
                                arguments: ProductDetailIntentHolder(
                                  id: provider.basketList.data[index].id,
                                  qty: provider.basketList.data[index].qty,
                                  selectedColorId: provider
                                      .basketList.data[index].selectedColorId,
                                  selectedColorValue: provider.basketList
                                      .data[index].selectedColorValue,
                                  basketPrice: provider
                                      .basketList.data[index].basketPrice,
                                  basketSelectedAttributeList: provider
                                      .basketList
                                      .data[index]
                                      .basketSelectedAttributeList,
                                  product:
                                      provider.basketList.data[index].product,
                                  heroTagImage: '',
                                  heroTagTitle: '',
                                  heroTagOriginalPrice: '',
                                  heroTagUnitPrice: '',
                                ));
                          },
                          onDeleteTap: () {
                            showDialog<dynamic>(
                                context: context,
                                builder: (BuildContext context) {
                                  return ConfirmDialogView(
                                      description: Utils.getString(context,
                                          'basket_list__confirm_dialog_description'),
                                      leftButtonText: Utils.getString(context,
                                          'basket_list__comfirm_dialog_cancel_button'),
                                      rightButtonText: Utils.getString(context,
                                          'basket_list__comfirm_dialog_ok_button'),
                                      onAgreeTap: () async {
                                        Navigator.of(context).pop();
                                        provider.deleteBasketByProduct(
                                            provider.basketList.data[index]);
                                      });
                                });
                          });
                    },
                  )),
                ),
                _CheckoutButtonWidget(provider: provider),
              ],
            );
          } else {
            widget.animationController.forward();
            final Animation<double> animation =
                Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: widget.animationController,
                    curve: const Interval(0.5 * 1, 1.0,
                        curve: Curves.fastOutSlowIn)));
            return AnimatedBuilder(
              animation: widget.animationController,
              builder: (BuildContext context, Widget child) {
                return FadeTransition(
                    opacity: animation,
                    child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 100 * (1.0 - animation.value), 0.0),
                      child: SingleChildScrollView(
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          padding:
                              const EdgeInsets.only(bottom: PsDimens.space120),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Image.asset(
                                'assets/images/empty_basket.png',
                                height: 150,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(
                                height: PsDimens.space32,
                              ),
                              Text(
                                Utils.getString(
                                    context, 'basket_list__empty_cart_title'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(),
                              ),
                              const SizedBox(
                                height: PsDimens.space20,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                    Utils.getString(context,
                                        'basket_list__empty_cart_description'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(),
                                    textAlign: TextAlign.center),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));
              },
            );
          }
        } else {
          return Container();
        }
      }),
    );
  }
}

class _CheckoutButtonWidget extends StatelessWidget {
  const _CheckoutButtonWidget({
    Key key,
    @required this.provider,
  }) : super(key: key);

  final BasketProvider provider;
  @override
  Widget build(BuildContext context) {
    double totalPrice = 0.0;
    int qty = 0;
    String currencySymbol;

    for (Basket basket in provider.basketList.data) {
      totalPrice += double.parse(basket.basketPrice) * double.parse(basket.qty);

      qty += int.parse(basket.qty);
      currencySymbol = basket.product.currencySymbol;
    }

    return Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.all(PsDimens.space8),
        decoration: BoxDecoration(
          color: PsColors.backgroundColor,
          border: Border.all(color: PsColors.mainLightShadowColor),

        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: PsDimens.space8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  '${Utils.getString(context, 'checkout__price')} $currencySymbol ${Utils.getPriceFormat(totalPrice.toString())}',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                Text(
                  '$qty  ${Utils.getString(context, 'checkout__items')}',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
              ],
            ),
            const SizedBox(height: PsDimens.space8),
            Card(
              elevation: 0,
              color: PsColors.mainColor,

              child: InkWell(
                onTap: () {
                  Utils.navigateOnUserVerificationView(provider, context,
                      () async {
                    await Navigator.pushNamed(
                        context, RoutePaths.checkout_container,
                        arguments: CheckoutIntentHolder(
                            publishKey: provider.psValueHolder.publishKey,
                            basketList: provider.basketList.data));
                  });
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: <Color>[
                        PsColors.mainColor,
                        PsColors.mainDarkColor,
                      ]),
                      borderRadius: const BorderRadius.all(
                          Radius.circular(5)),


                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[

                        const SizedBox(
                          width: PsDimens.space8,
                        ),
                        Text(
                          Utils.getString(
                              context, 'basket_list__checkout_button_name'),
                          style: Theme.of(context)
                              .textTheme
                              .button
                              .copyWith(color: PsColors.white),
                        ),
                      ],
                    )),
              ),
            ),
            const SizedBox(height: PsDimens.space8),
          ],
        ));
  }
}
