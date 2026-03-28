import React from 'react';
import { AbsoluteFill, Sequence, useCurrentFrame, interpolate } from 'remotion';

export interface ExerciseVideoProps {
  exerciseName: string;
  sets: string;
  difficulty: string;
  description: string;
  bodyArea: string;
  primaryColor: string;
}

export const ExerciseVideo: React.FC<ExerciseVideoProps> = ({
  exerciseName,
  sets,
  difficulty,
  description,
  bodyArea,
  primaryColor,
}) => {
  const frame = useCurrentFrame();

  const opacity = interpolate(frame, [0, 15], [0, 1]);
  const translateY = interpolate(frame, [0, 20], [30, 0]);

  const difficultyBg =
    difficulty === 'Kolay' ? '#C0EDD0' : difficulty === 'Orta' ? '#FEECCE' : '#FA746F';
  const difficultyColor =
    difficulty === 'Kolay' ? '#006D4E' : difficulty === 'Orta' ? '#6A5E46' : '#A83836';

  return (
    <AbsoluteFill style={{ backgroundColor: '#F9F9F7', fontFamily: 'Inter, sans-serif' }}>
      {/* Header — bölge adı + egzersiz adı */}
      <Sequence from={0} durationInFrames={90}>
        <AbsoluteFill
          style={{
            justifyContent: 'flex-start',
            padding: '60px 40px 0',
            opacity,
          }}
        >
          {/* Bölge badge */}
          <div
            style={{
              backgroundColor: primaryColor,
              color: 'white',
              padding: '8px 20px',
              borderRadius: '100px',
              fontSize: '18px',
              fontWeight: 600,
              display: 'inline-block',
              marginBottom: '24px',
            }}
          >
            {bodyArea}
          </div>

          {/* Egzersiz adı */}
          <h1
            style={{
              fontSize: '52px',
              fontWeight: 800,
              color: '#2F3332',
              transform: `translateY(${translateY}px)`,
              lineHeight: 1.2,
              marginBottom: '16px',
              margin: '0 0 16px 0',
            }}
          >
            {exerciseName}
          </h1>

          {/* Set/tekrar */}
          <div
            style={{
              fontSize: '28px',
              color: primaryColor,
              fontWeight: 600,
              transform: `translateY(${translateY}px)`,
            }}
          >
            {sets}
          </div>
        </AbsoluteFill>
      </Sequence>

      {/* Açıklama kartı */}
      <Sequence from={20} durationInFrames={70}>
        <AbsoluteFill
          style={{
            justifyContent: 'center',
            padding: '0 40px',
            opacity: interpolate(frame, [20, 35], [0, 1]),
          }}
        >
          <div
            style={{
              backgroundColor: 'white',
              borderRadius: '24px',
              padding: '32px',
              boxShadow: '0 8px 24px rgba(47,51,50,0.08)',
              fontSize: '24px',
              color: '#5C605E',
              lineHeight: 1.6,
              marginTop: '240px',
            }}
          >
            {description}
          </div>

          {/* Zorluk badge */}
          <div
            style={{
              marginTop: '24px',
              backgroundColor: difficultyBg,
              color: difficultyColor,
              padding: '8px 24px',
              borderRadius: '100px',
              fontSize: '20px',
              fontWeight: 700,
              display: 'inline-block',
            }}
          >
            {difficulty}
          </div>
        </AbsoluteFill>
      </Sequence>

      {/* Nurai watermark */}
      <AbsoluteFill
        style={{
          justifyContent: 'flex-end',
          alignItems: 'flex-end',
          padding: '30px',
          opacity: 0.4,
        }}
      >
        <span style={{ fontSize: '20px', fontWeight: 700, color: '#006D4E' }}>Nurai</span>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
