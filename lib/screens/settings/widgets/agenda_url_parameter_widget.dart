import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onyx/screens/agenda/agenda_export.dart';
import 'package:onyx/screens/agenda_config/page/agenda_config_page.dart';
import 'package:onyx/screens/login/login_export.dart';
import 'package:onyx/screens/settings/settings_export.dart';

class AgendaUrlParameterWidget extends StatelessWidget {
  const AgendaUrlParameterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          children: [
            TextSwitchWidget(
              text: 'Récupérer automatiquement les ressources de l\'agenda',
              value:
                  context.read<SettingsCubit>().state.settings.fetchAgendaAuto,
              onChanged: (bool b) {
                context.read<SettingsCubit>().modify(
                    settings: context
                        .read<SettingsCubit>()
                        .state
                        .settings
                        .copyWith(fetchAgendaAuto: b));
                context.read<AgendaCubit>().load(
                    dartus: context.read<AuthentificationCubit>().state.dartus!,
                    settings: context.read<SettingsCubit>().state.settings,
                    cache: false);
              },
            ),
            (!context.read<SettingsCubit>().state.settings.fetchAgendaAuto)
                ? Container(
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor.withOpacity(0.2),
                          ),
                          backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SafeArea(
                                child: AgendaConfigPage(
                                  onBack: (index) {
                                    context.read<SettingsCubit>().modify(
                                        settings: context
                                            .read<SettingsCubit>()
                                            .state
                                            .settings
                                            .copyWith(agendaId: index));
                                    context.read<AgendaCubit>().load(
                                        dartus: context
                                            .read<AuthentificationCubit>()
                                            .state
                                            .dartus!,
                                        settings: context
                                            .read<SettingsCubit>()
                                            .state
                                            .settings,
                                        cache: false);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Selectionner l\'agenda',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                    ),
                  )
                : Container(),
          ],
        );
      },
    );
  }
}
