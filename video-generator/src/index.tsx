import { Composition, registerRoot } from 'remotion';
import { ExerciseVideo } from './ExerciseVideo';
import type { ExerciseVideoProps } from './ExerciseVideo';

const RemotionRoot = () => {
  return (
    <Composition<ExerciseVideoProps>
      id="ExerciseVideo"
      component={ExerciseVideo}
      durationInFrames={90}
      fps={30}
      width={1080}
      height={1920}
      defaultProps={{
        exerciseName: 'Quad Set',
        sets: '3×15',
        difficulty: 'Kolay',
        description: 'Diz düz pozisyonda quad kasılması, 5 sn tut.',
        bodyArea: 'Diz / ACL',
        primaryColor: '#006D4E',
      }}
    />
  );
};

registerRoot(RemotionRoot);
