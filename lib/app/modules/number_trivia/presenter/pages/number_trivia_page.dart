import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../bloc/bloc.dart';
import '../widgets/trivia_controls_widget.dart';
import '../widgets/widgets.dart';

class NumberTriviaPage extends StatelessWidget {
  final numberTriviaBloc = Modular.get<NumberTriviaBloc>();

  Widget _buildBody(BuildContext context) {
    return BlocProvider(
      builder: (_) => numberTriviaBloc,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 10.0),
              //* Top half
              BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                builder: (context, state) {
                  if (state is Empty) {
                    return MessageDisplay(
                      message: 'Start searching...',
                    );
                  } else if (state is Loading) {
                    return LoadingWidget();
                  } else if (state is Loaded) {
                    return TriviaDisplay(numberTrivia: state.trivia);
                  } else if (state is Error) {
                    return MessageDisplay(
                      message: state.message,
                    );
                  }

                  return Container();
                },
              ),
              SizedBox(height: 10.0),
              //* Bottom half
              TriviaControls(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: _buildBody(context),
      ),
    );
  }
}
