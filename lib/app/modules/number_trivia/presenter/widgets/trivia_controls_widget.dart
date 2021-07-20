import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../bloc/bloc.dart';

class TriviaControls extends StatefulWidget {
  const TriviaControls({Key key}) : super(key: key);

  @override
  _TriviaControlsState createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();
  String inputStr;

  final numberTriviaBloc = Modular.get<NumberTriviaBloc>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: (value) => inputStr = value,
          onSubmitted: (_) => dispatchConcrete(),
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: RaisedButton(
                onPressed: dispatchConcrete,
                child: Text('Search'),
                color: Theme.of(context).accentColor,
                textTheme: ButtonTextTheme.primary,
              ),
            ),
            SizedBox(width: 10.0),
            Expanded(
                child: RaisedButton(
              onPressed: dispatchRandom,
              child: Text('Get Random Trivia'),
            )),
          ],
        ),
      ],
    );
  }

  void dispatchConcrete() {
    controller.clear();
    numberTriviaBloc.dispatch(GetTriviaForConcreteNumber(inputStr));
  }

  void dispatchRandom() => numberTriviaBloc.dispatch(GetTriviaForRandomNumber());
}
