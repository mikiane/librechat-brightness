import styles from './style.module.css'
import type { ComponentProps, ReactElement } from 'react'

const Logo = (props: ComponentProps<'svg'>): ReactElement => (
  <svg viewBox="0 0 1024 1024" {...props}>
    <defs>
      <linearGradient id="LibreChat_svg__a">
        <stop stopColor="#21facf" offset={0} />
        <stop stopColor="#0970ef" offset={1} />
      </linearGradient>
      <linearGradient
        id="LibreChat_svg__d"
        x1={68.454}
        x2={198.59}
        y1={246.73}
        y2={96.35}
        gradientTransform="translate(-5.754 -56.594)"
        gradientUnits="userSpaceOnUse"
      >
        <stop stopColor="#72004e" offset={0} />
        <stop stopColor="#0015b1" offset={1} />
      </linearGradient>
      <linearGradient
        id="LibreChat_svg__b"
        x1={56.735}
        x2={155.2}
        y1={246.96}
        y2={58.575}
        gradientUnits="userSpaceOnUse"
      >
        <stop stopColor="#4f00da" offset={0} />
        <stop stopColor="#e5311b" offset={1} />
      </linearGradient>
      <linearGradient
        id="LibreChat_svg__c"
        x1={68.454}
        x2={198.59}
        y1={246.73}
        y2={96.35}
        gradientUnits="userSpaceOnUse"
        xlinkHref="#LibreChat_svg__a"
      />
      <linearGradient
        id="LibreChat_svg__e"
        x1={54.478}
        x2={192.1}
        y1={247.56}
        y2={9.809}
        gradientTransform="translate(-9.551 48.787) scale(.87923)"
        gradientUnits="userSpaceOnUse"
      >
        <stop stopColor="#dc180d" offset={0} />
        <stop stopColor="#f96e20" offset={0.5} />
        <stop stopColor="#f4ce41" offset={1} />
      </linearGradient>
      <linearGradient
        id="LibreChat_svg__f"
        x1={39.468}
        x2={154.99}
        y1={204.22}
        y2={124.47}
        gradientUnits="userSpaceOnUse"
        xlinkHref="#LibreChat_svg__a"
      />
    </defs>
    <path
      d="M105.5 24.43c-48.394 0-87.625 39.231-87.625 87.625a87.626 87.626 0 0020.253 55.954c.252-.422.536-.824.858-1.206 4.892-5.81 10.427-10.214 18.946-19.252 3.787-4.018 6.341 15.63 7.643 14.309 1.325-1.344.148-19.001 3.507-24.674 6.056-10.228 10.733-18.067 22.336-30.607 2.844-3.074 5.533 11.223 6.806 9.236 1.142-1.782-.27-18.641 1.566-23.773 4.882-13.647 3.363-13.21 15.582-31.378 2.098-3.12 6.496 7.94 7.215 6.327.701-1.574-.841-11.131-.672-15.805.372-3.15 3.604-13.06 7.706-23.367a87.628 87.628 0 00-24.12-3.39zm43.142 11.356c5.566 61.595-18.426 120.7-62.796 161.65a87.627 87.627 0 0019.655 2.239c48.394 0 87.625-39.231 87.625-87.625a87.625 87.625 0 00-44.484-76.268z"
      fill="url(#LibreChat_svg__d)"
      transform="translate(-9.798 -9.798) scale(4.946)"
    />
    <path
      transform="translate(-37.247 -293.758) scale(4.946)"
      d="M148.16 59.393c-7.71 9.399-19.951 42.888-20.696 49.204-.17 4.674 1.373 14.231.672 15.805-.72 1.613-5.117-9.446-7.215-6.327-12.22 18.168-10.7 17.731-15.582 31.378-1.836 5.132-.425 21.99-1.567 23.773-1.273 1.987-3.962-12.31-6.806-9.236-11.603 12.54-16.28 20.38-22.336 30.607-3.36 5.673-2.182 23.33-3.506 24.674-1.302 1.322-3.857-18.326-7.644-14.309-8.52 9.038-14.054 13.441-18.946 19.252-5.198 6.174-.782 17.584-5.067 35.383l.145.221c77.447-50.308 101.52-127.16 107.61-181.19-.68 63.93-29.41 142.78-105.33 184.65l.112.172c20.241-2.181 22.307 10.458 44.562-4.284 55.792-48.277 81.856-124.29 61.593-199.78z"
      fill="url(#LibreChat_svg__f)"
    />
  </svg>
)

export default function LCLogo() {
  return (
    <div className={styles.pagelogo}>
      <Logo />
    </div>
  )
}

export function LogoTitle() {
  return <Logo />
}
