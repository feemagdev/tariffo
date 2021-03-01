import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';

import 'package:stripe_payment/stripe_payment.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'new_payment_service.dart';

class ExistingCardsPage extends StatefulWidget {
  final String plan;
  final String amounts;
  final String currentUserId;
  ExistingCardsPage({Key key, this.plan, this.amounts, this.currentUserId})
      : super(key: key);

  @override
  ExistingCardsPageState createState() => ExistingCardsPageState();
}

class ExistingCardsPageState extends State<ExistingCardsPage> {
  var planDays;

  //these are Examples of the Card Data
  List cards = [
    {
      'cardNumber': '4242424242424242',
      'expiryDate': '04/24',
      'cardHolderName': 'Muhammad Ahsan Ayaz',
      'cvvCode': '424',
      'showBackView': false,
    },
    {
      'cardNumber': '4242424242424242',
      'expiryDate': '04/23',
      'cardHolderName': 'Tracer',
      'cvvCode': '123',
      'showBackView': false,
    }
  ];

  payViaExistingCard(BuildContext context, card) async {
    DocumentReference reference = Firestore.instance
        .collection('SuperUser')
        .document('${widget.currentUserId}');
    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var expiryArr = card['expiryDate'].split('/');
    CreditCard stripeCard = CreditCard(
      number: card['cardNumber'],
      expMonth: int.parse(expiryArr[0]),
      expYear: int.parse(expiryArr[1]),
    );

    var response = await StripeService.payViaExistingCard(
        amount: "${widget.amounts}", currency: 'USD', card: stripeCard);

    await dialog.hide();
    Scaffold.of(context)
        .showSnackBar(SnackBar(
          content: Text(response.message),
          duration: new Duration(milliseconds: 1200),
        ))
        .closed
        .then((_) async {
      if (response.success == true) {
        switch (widget.plan) {
          case "Bronze":
            setState(() {
              planDays = 3;
            });

            break;
          case "Gold":
            setState(() {
              planDays = 6;
            });
            break;

          case "Premium":
            setState(() {
              planDays = 12;
            });
            break;
        }
        await Firestore.instance.runTransaction((transaction) {
          return transaction.update(reference, {
            "expired": false,
            "expired_on": new DateTime.now()
                .add(new Duration(days: planDays * 30))
                .millisecondsSinceEpoch,
            "notified": false,
            "plan": '${widget.plan}'
          });
        });
      }
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose existing card'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: cards.length,
          itemBuilder: (BuildContext context, int index) {
            var card = cards[index];
            return InkWell(
              onTap: () {
                print("plan is " + widget.plan);
                payViaExistingCard(context, card);
              },
              child: CreditCardWidget(
                cardNumber: card['cardNumber'],
                expiryDate: card['expiryDate'],
                cardHolderName: card['cardHolderName'],
                cvvCode: card['cvvCode'],
                showBackView: false,
              ),
            );
          },
        ),
      ),
    );
  }
}
