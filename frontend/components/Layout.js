import React from 'react'

const Layout = ({ children }) => {
  return (
    <div>
      <header>
        <nav>
          <ul>
            <li><a href="/">Home</a></li>
            <li><a href="/analysis">Analysis</a></li>
          </ul>
        </nav>
      </header>
      <main>{children}</main>
      <footer>© 2024 VALORANT Analysis Tool</footer>
    </div>
  )
}

export default Layout
