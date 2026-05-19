import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'TRUSTA · K-뷰티 해외 문구 RegTech',
  description: '해외 진출 전, 화장품 문구부터 검역하세요.',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ko">
      <body>
        <div className="page">{children}</div>
      </body>
    </html>
  )
}
