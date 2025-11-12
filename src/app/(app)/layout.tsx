'use client';

import Link from 'next/link';
import { useState } from 'react';

export default function AppLayout({ children }: { children: React.ReactNode }) {
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);

  return (
    <div className="relative mx-auto h-screen max-h-[950px] w-full max-w-[480px] overflow-hidden">
      <div className={`absolute inset-0 flex flex-col bg-background-light dark:bg-background-dark transition-transform duration-300 ${isDrawerOpen ? 'translate-x-64' : ''}`}>
        <header className="flex h-16 shrink-0 items-center justify-between bg-white px-4 shadow-sm dark:bg-surface-dark">
          <div className="flex items-center gap-4">
            <button className="text-slate-600 dark:text-slate-300" onClick={() => setIsDrawerOpen(!isDrawerOpen)}>
              <span className="material-symbols-outlined text-3xl">menu</span>
            </button>
            <h1 className="text-xl font-bold text-slate-900 dark:text-white">Home</h1>
          </div>
          <button className="text-slate-600 dark:text-slate-300">
            <span className="material-symbols-outlined text-3xl">search</span>
          </button>
        </header>
        <main className="flex-grow overflow-y-auto p-4">
          {children}
        </main>
      </div>
      {isDrawerOpen && <div className="absolute inset-0 bg-black/40" onClick={() => setIsDrawerOpen(false)}></div>}
      <div className={`absolute top-0 left-0 flex h-full w-5/6 max-w-sm flex-col bg-background-light p-6 pt-16 shadow-2xl dark:bg-[#1a2933] transition-transform duration-300 ${isDrawerOpen ? 'translate-x-0' : '-translate-x-full'}`}>
        <div className="flex items-center gap-4">
          <div className="h-16 w-16 shrink-0 rounded-full bg-cover bg-center bg-no-repeat" style={{ backgroundImage: 'url("https://lh3.googleusercontent.com/aida-public/AB6AXuAtmUsWf6YdwgA_-ZBqpiAmil6WrzaNp_nUir3CkmnWFYhiLMmV13_71QSq8o4lilgtbDPcCryVqoSaLbIyzLviJ_jbB9MiZXOGttf_amRmAjevaBLmJ3Xk-fUM0YHgqyYNUZ1oh5qCKIAgyc8uf6wOXfi9cG1jGCTRmBIcqh4a7WNq9fYeE9YR1oMdLNAL2i4DVH_CXKDwPUqV0NUIgDDn9Y4GGYEXR0tDZksZYM0YWTIbG8VuJIaJ7lE3lO1BpWE4Ub6VRrGEEFDh")' }}></div>
          <div className="flex flex-col">
            <p className="text-lg font-bold text-slate-900 dark:text-white">James</p>
            <p className="text-sm text-slate-500 dark:text-slate-400">View Profile</p>
          </div>
        </div>
        <nav className="mt-8 flex flex-col gap-2">
          <Link className="flex items-center gap-6 rounded-lg p-4 text-slate-700 hover:bg-slate-200 dark:text-slate-300 dark:hover:bg-slate-700/50" href="/">
            <span className="material-symbols-outlined">home</span>
            <span className="text-base font-semibold">Home Page</span>
          </Link>
          {/* Add other nav links here */}
        </nav>
      </div>
    </div>
  );
}
