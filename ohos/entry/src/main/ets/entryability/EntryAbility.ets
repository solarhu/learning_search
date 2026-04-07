import hilog from '@ohos.hilog';
import Ability from '@ohos.app.ability.Ability';
import Window from '@ohos.window';
import flutter from 'flutter';

const TAG: string = 'EntryAbility';
const DOMAIN_NUMBER: number = 0x0000;

export default class EntryAbility extends Ability {
  onCreate(want, launchParam) {
    hilog.info(DOMAIN_NUMBER, TAG, 'onCreate');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    hilog.info(DOMAIN_NUMBER, TAG, 'onWindowStageCreate');
    windowStage.loadContent('flutter:///');
  }

  onWindowStageDestroy() {
    hilog.info(DOMAIN_NUMBER, TAG, 'onWindowStageDestroy');
  }

  onForeground() {
    hilog.info(DOMAIN_NUMBER, TAG, 'onForeground');
  }

  onBackground() {
    hilog.info(DOMAIN_NUMBER, TAG, 'onBackground');
  }
};
