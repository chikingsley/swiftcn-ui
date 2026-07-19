import { Route, Routes } from "react-router-dom"
import IndexPage from "./pages/IndexPage"
import PilotPage from "./pages/PilotPage"
import ShowcasePage from "./pages/ShowcasePage"

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<IndexPage />} />
      <Route path="/c/:id" element={<ShowcasePage />} />
      <Route path="/pilot/:component/:state" element={<PilotPage />} />
    </Routes>
  )
}
