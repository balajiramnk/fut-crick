import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:futcrick_user/constants.dart';
import 'package:futcrick_user/datamodel/MatchDataModel.dart';
import 'package:futcrick_user/pages/matches/TeamDetails.dart';
import 'package:intl/intl.dart';

class MatchCard extends StatefulWidget {
  final MatchDataModel matchData;
  final File file;
  final bool isPreview;
  final bool isLive;
  final bool isUpcoming;
  final bool isFinished;
  final bool isClickable;

  const MatchCard(
      {Key key,
      this.matchData,
      this.file,
      this.isPreview = false,
      this.isLive = false,
      this.isUpcoming = false,
      this.isFinished = false,
      this.isClickable = true})
      : super(key: key);

  @override
  _MatchCardState createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  String _startTime;
  String _endTime;
  String _matchDate;
  String stateValue;
  List<String> stateList;

  @override
  void initState() {
    super.initState();
    _startTime = DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(
        widget.matchData.startTime.millisecondsSinceEpoch));
    _endTime = DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(
        widget.matchData.endTime.millisecondsSinceEpoch));
    _matchDate = DateFormat('dd - MM - yyyy').format(
        DateTime.fromMillisecondsSinceEpoch(
            widget.matchData.date.millisecondsSinceEpoch));
    stateList = ['Live', 'Upcoming', 'Finished'];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      width: 320,
      child: InkWell(
        splashColor: widget.isClickable ? Colors.white24 : Colors.transparent,
        highlightColor:
            widget.isClickable ? Colors.white24 : Colors.transparent,
        focusColor: widget.isClickable ? Colors.white24 : Colors.transparent,
        onTap: widget.isClickable
            ? () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TeamDetails(
                              matchId: widget.matchData.matchId,
                              homeTeamShortName:
                                  widget.matchData.homeTeamShortName,
                              awayTeamShortName:
                                  widget.matchData.awayTeamShortName,
                              playerScoresT1: widget.matchData.playerScoresT1,
                              playerScoresT2: widget.matchData.playerScoresT2,
                              matchData: widget.matchData,
                            )));
              }
            : () {},
        child:
            // Stack(
            //   children: [
            Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: secondaryDark,
                border: Border.all(
                    color: widget.isLive ? Colors.white : Colors.white38,
                    width: 2),
                boxShadow: [
                  BoxShadow(
                      color:
                          widget.isLive ? Colors.white54 : Colors.transparent,
                      offset: Offset(1, 1),
                      blurRadius: 10)
                ],
                borderRadius: BorderRadius.all(Radius.circular(6)),
                image: DecorationImage(
                  image: widget.isPreview
                      ? FileImage(widget.file)
                      : NetworkImage(widget.matchData.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                    color: backgroundColor.withOpacity(0.5),
                    borderRadius: BorderRadius.all(Radius.circular(6))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      '',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Ubuntu',
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              // backgroundImage: AssetImage(
                              //     'assets/images/${widget.matchData.homeTeamShortName}.png'),
                              radius: 30.0,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Image.asset(
                                    'assets/images/${widget.matchData.homeTeamShortName}.png'),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              widget.matchData.homeTeamShortName,
                              style: TextStyle(
                                fontFamily: 'FiraSans',
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            )
                          ],
                        ),
                        widget.isUpcoming
                            ? Container()
                            : Row(
                                children: [
                                  Stack(
                                    children: [
                                      Text(
                                        '${widget.matchData.goalT1} - ${widget.matchData.goalT2}',
                                        style: TextStyle(
                                            fontFamily: 'Ubuntu',
                                            fontSize: 50,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        '${widget.matchData.goalT1} - ${widget.matchData.goalT2}',
                                        style: TextStyle(
                                            fontFamily: 'Ubuntu',
                                            fontSize: 50,
                                            foreground: Paint()
                                              ..style = PaintingStyle.stroke
                                              ..strokeWidth = 2
                                              ..color = backgroundColor,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 30.0,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Image.asset(
                                    'assets/images/${widget.matchData.awayTeamShortName}.png'),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              widget.matchData.awayTeamShortName,
                              style: TextStyle(
                                fontFamily: 'FiraSans',
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_startTime - $_endTime\n$_matchDate',
                            style: TextStyle(
                                fontFamily: 'FiraSans', color: Colors.white70),
                          ),
                          SizedBox(width: 15),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'At ${widget.matchData.place}',
                                  style: TextStyle(
                                      fontFamily: 'FiraSans',
                                      color: Colors.white70),
                                  overflow: TextOverflow.clip,
                                  textAlign: TextAlign.right,
                                ),
                                widget.isClickable
                                    ? Text(
                                        'View more details >',
                                        style: TextStyle(
                                          fontFamily: 'FiraSans',
                                          fontSize: 12,
                                          color: Colors.white,
                                          decoration: TextDecoration.underline,
                                        ),
                                        overflow: TextOverflow.clip,
                                        textAlign: TextAlign.right,
                                      )
                                    : SizedBox(),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            widget.isLive
                ? Positioned(
                    left: 8,
                    top: 8,
                    child: Row(
                      children: [
                        Container(
                          height: 18,
                          width: 18,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: backgroundColor, width: 2)),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Live',
                          style: TextStyle(fontFamily: 'Ubuntu'),
                        )
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
