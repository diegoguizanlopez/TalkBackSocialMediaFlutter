import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TalkBack/Models/export_models.dart';
import 'package:TalkBack/Provider/export_provider.dart';
import 'package:TalkBack/Widgets/export_methods.dart';
import 'package:TalkBack/Widgets/google_fonts_style.dart';

class Search extends StatelessWidget {
  const Search({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProviderSettings prov =
        Provider.of<ProviderSettings>(context, listen: true);
    return Container(
      color: prov.lightMode ? Colors.white : Colors.black87,
      child: _createSearch(),
    );
  }
}

class _createSearch extends StatefulWidget {
  const _createSearch({Key? key}) : super(key: key);

  @override
  State<_createSearch> createState() => _createSearchState();
}

class _createSearchState extends State<_createSearch>
    with AutomaticKeepAliveClientMixin {
  String valueText = "";
  bool working = false;
  int firstSearch = 0;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    UsersData provider = Provider.of<UsersData>(context, listen: true);
    return Column(
      children: [
        StyleContainer(
            edgeInsets: EdgeInsets.only(top: 20, bottom: 5),
            child: TextField(
                style: TextStyle(color: Colors.white),
                onSubmitted: (value) => setState(() {
                      working = true;
                      valueText = value;
                    }),
                decoration: const InputDecoration(
                    prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                )))),
        working?StyleCircularprogress():Container(),
        FutureBuilder(
          future: _getValues(provider),
          builder:
              (BuildContext context, AsyncSnapshot<List<UserApp>> snapshot) {
            if (snapshot.hasData) {
              working = false;
              if(snapshot.data!.isNotEmpty){
                firstSearch++;
              }
              return Expanded(
                  child: snapshot.data!.isEmpty
                      ? firstSearch != 0
                          ? !working?_infoContainer():Container()
                          : Container()
                      : ListView.separated(
                          itemBuilder: (BuildContext context, int index) {
                            return _createIndividualSpace(
                                usuario: snapshot.data![index]);
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(
                              color: Colors.black12,
                              thickness: 2,
                            );
                          },
                          itemCount: snapshot.data!.length,
                        ));
            } else {
              return StyleCircularprogress();
            }
          },
        )
      ],
    );
  }

  Future<List<UserApp>> _getValues(UsersData provider)async{
    working = true;
    var value = await provider.getListByValue(busq: valueText);
    setState(() {working=false;});
    return value;
  }

  ///Mantiene viva la pestaña hasta que se cierra
  @override
  bool get wantKeepAlive => true;
}

class _createIndividualSpace extends StatefulWidget {
  UserApp usuario;
  _createIndividualSpace({Key? key, required this.usuario}) : super(key: key);

  @override
  State<_createIndividualSpace> createState() => _createIndividualSpaceState();
}

class _createIndividualSpaceState extends State<_createIndividualSpace> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.of(context).pushNamed("profile", arguments: widget.usuario),
      child: Container(
        margin: EdgeInsets.all(10),
        height: 50,
        width: double.infinity,
        child: ListTile(
          title: Container(
              margin: EdgeInsets.only(left: 20),
              child: GoogleFontsStyle(
                body: widget.usuario.username,
              )),
          leading:
              CircleAvatar(backgroundImage: NetworkImage(widget.usuario.foto)),
        ),
      ),
    );
  }
}

class _infoContainer extends StatelessWidget {
  const _infoContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GoogleFontsStyle(
          body: "Sorry there is not a username with that search"),
    );
  }
}
