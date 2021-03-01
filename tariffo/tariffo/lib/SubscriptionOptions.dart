import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:tariffo/HomePage.dart';
import 'package:tariffo/existing_cards.dart';
import 'package:tariffo/payment_service.dart';

class SubscriptionOptions extends StatefulWidget {

  bool subscriptionExpired;

  String userId;
  SubscriptionOptions({this.subscriptionExpired, this.userId});
  @override
  _SubscriptionOptionsState createState() => _SubscriptionOptionsState();


}

class _SubscriptionOptionsState extends State<SubscriptionOptions> {
  @override
  void initState() {
    // TODO: implement initState
    StripeService.init();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Subscription"),
        centerTitle: true,
        leading: IconButton(icon:Icon(Icons.arrow_back_ios,color: Colors.white60,),onPressed: (){
          Navigator.pop(context);
          Navigator.push(context, new MaterialPageRoute(builder: (_)=>Homepage()));
        },),

      ),
      body: SingleChildScrollView(

        child: Container(
          height: MediaQuery.of(context).size.height*0.85,
          width: MediaQuery.of(context).size.width*0.95,

          child: Column(
            children: <Widget>[

              SizedBox(height:10.0),
              Center(child: Text("Choose Subscription plan for profile promotion",style:TextStyle(fontSize:14.0,color:Theme.of(context).primaryColor,fontWeight:FontWeight.bold,))),
              SizedBox(height:10.0),
              Container(
                height: MediaQuery.of(context).size.height*0.7/3,
                width: MediaQuery.of(context).size.width*0.9,
                child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width*0.7,
                        height: MediaQuery.of(context).size.height*0.7/3,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                              width: 1.5,
                              color: Theme.of(context).primaryColor),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '8,49\$',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25.0,

                                ),
                              ),
                              SizedBox(height:10.0),
                              Text(
                                '3 months Subscription',
                                style: TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 20.0,),
                      GestureDetector(
                        onTap: (){
                          showBottomSheet('Bronze','84900',context);
                        },
                        child: Container(
                          height:50.0,
                          width: 50.0,

                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor,
                            borderRadius:
                            BorderRadius.circular(40.0),
                            border: Border.all(
                                width: 3.0,
                                color: Theme.of(context)
                                    .primaryColor),
                          ),
                          child: Center(
                              child: Icon(Icons.arrow_forward_ios,color: Colors.white60,size: 28.0,)

                            // Text(
                            //   'Platinum',
                            //   style: TextStyle(
                            //       fontWeight: FontWeight.bold,
                            //       fontSize: 12.0,
                            //       color: Colors.white),
                            // ),
                          ),
                        ),
                      ),
                    ]

                ),
              ),

              SizedBox(height:10.0),
              Container(
                height: MediaQuery.of(context).size.height*0.7/3-10,
                width: MediaQuery.of(context).size.width*0.9,
                child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width*0.7,
                        height: MediaQuery.of(context).size.height*0.7/3-10,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(
                              width: 1.5,
                              color: Theme.of(context).primaryColor),
                        ),
                        child: Center(



                            child:Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '12,49\$',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0,

                                  ),
                                ),
                                SizedBox(height:30.0),
                                Text(
                                  '6 months Subscription',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),

                              ],
                            )
                        ),
                      ),
                      SizedBox(width: 20.0,),
                      GestureDetector(
                        onTap: (){
                          showBottomSheet('Gold','124900',context);
                        },
                        child: Container(
                          height:50.0,
                          width: 50.0,

                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor,
                            borderRadius:
                            BorderRadius.circular(40.0),
                            border: Border.all(
                                width: 3.0,
                                color: Theme.of(context)
                                    .primaryColor),
                          ),
                          child: Center(
                              child: Icon(Icons.arrow_forward_ios,color: Colors.white60,size: 28.0,)

                            // Text(
                            //   'Platinum',
                            //   style: TextStyle(
                            //       fontWeight: FontWeight.bold,
                            //       fontSize: 12.0,
                            //       color: Colors.white),
                            // ),
                          ),
                        ),
                      ),
                    ]

                ),
              ),
              SizedBox(height:10.0),
              Container(
                height: MediaQuery.of(context).size.height*0.7/3-10,
                width: MediaQuery.of(context).size.width*0.9,
                child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width*0.7,
                        height: MediaQuery.of(context).size.height*0.7/3-10,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                              width: 1.5,
                              color: Theme.of(context).primaryColor),
                        ),
                        child: Center(


                            child:Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  '15,99\$',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0,

                                  ),
                                ),
                                SizedBox(height:10.0),
                                Text(
                                  '12 months Subscription',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),

                              ],
                            )
                        ),
                      ),
                      SizedBox(width: 20.0,),
                      GestureDetector(
                        onTap: (){
                          showBottomSheet('Platinum','159900',context);
                        },
                        child: Container(
                          height:50.0,
                          width: 50.0,

                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor,
                            borderRadius:
                            BorderRadius.circular(40.0),
                            border: Border.all(
                                width: 3.0,
                                color: Theme.of(context)
                                    .primaryColor),
                          ),
                          child: Center(
                            child: Icon(Icons.arrow_forward_ios,color: Colors.white60,size: 28.0,)
                            
                            // Text(
                            //   'Platinum',
                            //   style: TextStyle(
                            //       fontWeight: FontWeight.bold,
                            //       fontSize: 12.0,
                            //       color: Colors.white),
                            // ),
                          ),
                        ),
                      ),
                    ]

                ),
              ),

              SizedBox(height:20.0),


            ],
          ),
        ),
      ),
    );
  }


  onItemPress(BuildContext context, int index, String plan,String amounts) async {


    print('amount at on Item Pressed ???  $amounts');

    switch(index) {
      case 0:
        if(widget.subscriptionExpired==true){
          payViaNewCard(context,plan,amounts);
        }else{

          print('already subscribed ');
        }

        break;
      case 1:
        if(widget.subscriptionExpired==true){
          Navigator.push(context, new MaterialPageRoute(builder: (_)=>ExistingCardsPage(plan: plan,amounts: amounts,currentUserId:widget.userId)));
        }else{

          print('already hjkkj subscribed ');
        }
        break;
    }
  }

  payViaNewCard(BuildContext context, String plan,String amounts) async {


    print('amount at pay Via New Card???  $amounts');
    int planDays;
    DocumentReference reference =Firestore.instance.collection('SuperUser').document('${widget.userId}');

    ProgressDialog dialog = new ProgressDialog(context);
    dialog.style(message: 'Please wait...');
    await dialog.show();
    var response =
    await StripeService.payWithNewCard(amount: amounts, currency: 'USD');
    await dialog.hide();
    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(response.message),
        duration: new Duration(
            milliseconds: response.success == true ? 1200 : 3000)));

    if (response.success == true) {
      switch (plan) {
        case "Basic":
          setState(() {
            planDays = 7;
          });

          break;
        case "Standard":
          setState(() {
            planDays = 15;
          });
          break;

        case "Premium":
          setState(() {
            planDays = 30;
          });
          break;
      }
      Firestore.instance.runTransaction((transaction) {

        return transaction.update(reference, {
          "expired":false,
          "expired_on":new DateTime.now().add(new Duration(days:planDays*30)).millisecondsSinceEpoch,
          "notified":false,
          "plan":'$plan'
        });
      });
    }
  }


  void showBottomSheet(String plan, String amountsTobeCharge,BuildContext contexts) {

    showModalBottomSheet(
        isScrollControlled: true,
        enableDrag: true,
        context: context ,
        builder: (BuildContext context){

          return Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height*0.5,
            child: ListView.separated(
                itemBuilder: (context, index) {
                  Icon icon;
                  Text text;

                  switch(index) {
                    case 0:
                      icon = Icon(Icons.add_circle, color: Theme.of(context).primaryColor);
                      text = Text('Pay via new card');
                      break;
                    case 1:
                      icon = Icon(Icons.credit_card, color: Theme.of(context).primaryColor);
                      text = Text('Pay via existing card');
                      break;
                  }

                  return InkWell(
                    onTap: () {
                      onItemPress(context, index,plan,amountsTobeCharge);
                    },
                    child: ListTile(
                      title: text,
                      leading: icon,
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  color: Theme.of(context).primaryColor,
                ),
                itemCount: 2
            ),
          );
        });
  }
}
